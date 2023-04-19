<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ExternalCodeLists">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../ExternalCodeLists[FK_CodeLists = $parentKey]">      
              <xsl:element name="ExternalCodeList">
                <xsl:if test="string-length(normalize-space(Dictionary)) &gt; 0">
                  <xsl:attribute name="Dictionary"><xsl:value-of select="Dictionary"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(Version)) &gt; 0">
                  <xsl:attribute name="Version"><xsl:value-of select="Version"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(href)) &gt; 0">
                  <xsl:attribute name="href"><xsl:value-of select="href"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(ref)) &gt; 0">
                  <xsl:attribute name="ref"><xsl:value-of select="ref"/></xsl:attribute>
                </xsl:if>
              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>