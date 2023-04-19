<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:def="http://www.cdisc.org/ns/def/v2.1"
                xmlns="http://www.cdisc.org/ns/odm/v1.3">

  <xsl:template name="PDFPageRefs">

    <xsl:element name="def:PDFPageRef">
      
      <xsl:if test="string-length(normalize-space(PageRefs)) &gt; 0">
        <xsl:attribute name="PageRefs">
          <xsl:value-of select="PageRefs"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(normalize-space(FirstPage)) &gt; 0">
        <xsl:attribute name="FirstPage">
          <xsl:value-of select="FirstPage"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(normalize-space(LastPage)) &gt; 0">
        <xsl:attribute name="LastPage">
          <xsl:value-of select="LastPage"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(normalize-space(Type)) &gt; 0">
        <xsl:attribute name="Type">
          <xsl:value-of select="Type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(normalize-space(Title)) &gt; 0">
        <xsl:attribute name="Title">
          <xsl:value-of select="Title"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:element>

  </xsl:template>

</xsl:stylesheet>