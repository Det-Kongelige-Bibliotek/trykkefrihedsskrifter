<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:a="http://www.loc.gov/standards/alto/ns-v3#"
	       xmlns:xlink="http://www.w3.org/1999/xlink"
	       xmlns="http://www.tei-c.org/ns/1.0" 
	       exclude-result-prefixes="a xlink"
	       version="2.0">


  <xsl:template match="a:alto">
    <xsl:param name="img_src" select="a:Description/a:sourceImageInformation/a:fileName"/>
    <xsl:param name="volume" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:param name="n" select="''"/>
    <xsl:apply-templates select="a:Layout">
      <xsl:with-param name="img_src" select="$img_src"/>
      <xsl:with-param name="volume" select="$volume"/>
      <xsl:with-param name="work" select="$work"/>
      <xsl:with-param name="n" select="$n"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="a:Layout">
    <xsl:param name="img_src" select="''"/>
    <xsl:param name="volume" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:param name="n" select="''"/>
    <!-- div -->
      <xsl:apply-templates>
	<xsl:with-param name="img_src" select="$img_src"/>
	<xsl:with-param name="volume" select="$volume"/>
	<xsl:with-param name="work" select="$work"/>
	<xsl:with-param name="n" select="$n"/>
      </xsl:apply-templates>
    <!-- /div -->
  </xsl:template>

  <xsl:template match="a:Page">
    <xsl:param name="img_src" select="''"/>
    <xsl:param name="volume" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:param name="n" select="''"/>
    <xsl:param name="barcode" select="substring-before($img_src,'_')"/>
    <pb n="{$n}" xml:id="w{$work}_p{$n}" facs="{concat($volume,'_',$barcode,'/',substring-before($img_src,'.tif'))}"/>
    <xsl:apply-templates>
      <xsl:with-param name="img_src" select="$img_src"/>
      <xsl:with-param name="volume" select="$volume"/>
      <xsl:with-param name="work" select="$work"/>
      <xsl:with-param name="n" select="$n"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="a:ComposedBlock">
    <xsl:param name="img_src" select="''"/>
    <xsl:param name="volume" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:param name="n" select="''"/>

    <xsl:for-each select="a:TextBlock">
    
      <xsl:variable name="line_count"
                    select="count(preceding-sibling::a:TextBlock)"/>
    
      <xsl:choose>
        <xsl:when test="$n=1 and $line_count&lt;=4">
          <head>
            <xsl:variable name="block_id" select="concat('head_w',$work,'_p',$n,'_b',@ID)"/>
            <xsl:attribute name="xml:id" select="$block_id"/>
            <xsl:apply-templates select=".">
              <xsl:with-param name="img_src" select="$img_src"/>
              <xsl:with-param name="volume" select="$volume"/>
              <xsl:with-param name="work" select="$work"/>
              <xsl:with-param name="mode">head</xsl:with-param>
              <xsl:with-param name="n" select="$n"/>
            </xsl:apply-templates>
          </head>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select=".">
            <xsl:with-param name="img_src" select="$img_src"/>
            <xsl:with-param name="volume" select="$volume"/>
            <xsl:with-param name="work" select="$work"/>
            <xsl:with-param name="mode">body</xsl:with-param>
            <xsl:with-param name="n" select="$n"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="a:TextBlock">
    <xsl:param name="img_src" select="''"/>
    <xsl:param name="volume" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:param name="mode" select="'body'"/>
    <xsl:param name="n" select="''"/>

    <xsl:variable name="bid" select="@ID"/>
    <xsl:variable name="block"><xsl:apply-templates>
      <xsl:with-param name="img_src" select="$img_src"/>
      <xsl:with-param name="volume" select="$volume"/>
      <xsl:with-param name="work" select="$work"/>
      <xsl:with-param name="n" select="$n"/>
    </xsl:apply-templates></xsl:variable>

    <xsl:variable name="block_id" select="concat('w',$work,'_p',$n,'_b',$bid)"/>
    
    <xsl:choose>
      <xsl:when
          test="string-length(normalize-space($block)) &gt; 0">
        <xsl:choose>
          <xsl:when test="$mode='body'">
            <xsl:element name="p">
              <xsl:attribute name="xml:id"><xsl:value-of select="$block_id"/></xsl:attribute>
              <xsl:value-of select="normalize-space($block)"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="normalize-space($block)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment> Block <xsl:attribute name="xml:id"><xsl:value-of select="$block_id"/></xsl:attribute> is empty</xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="a:TextLine">
    <xsl:param name="n" select="''"/>
    <xsl:param name="work" select="''"/>
    <xsl:apply-templates><xsl:with-param name="n" select="$n"/></xsl:apply-templates><lb/><xsl:text></xsl:text>
  </xsl:template>

  <xsl:template match="a:SP">
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="a:String">
    <xsl:param name="n" select="''"/>
    <xsl:param name="work" select="''"/>
    <!-- xsl:value-of select="concat('vol',$volume,'_H',@HEIGHT,'W',@WIDTH,'V',@VPOS,'H',@HPOS)"/ >
    <xsl:variable name="id">
      <xsl:value-of select="concat('vol',$volume,$n,'_',@ID)"/>
    </xsl:variable -->
    <xsl:choose>
      <xsl:when test="@SUBS_TYPE='HypPart1'">
	<xsl:value-of select="normalize-space(@SUBS_CONTENT)"/>
      </xsl:when>
      <xsl:when test="@SUBS_TYPE='HypPart2'">
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="normalize-space(@CONTENT)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
