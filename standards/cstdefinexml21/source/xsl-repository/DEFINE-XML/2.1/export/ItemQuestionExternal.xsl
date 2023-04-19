<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemQuestionExternal">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../ItemQuestionExternal[FK_ItemDefs = $parentKey]">      
              <xsl:element name="ExternalQuestion">
                <xsl:attribute name="Dictionary"><xsl:value-of select="Dictionary"/></xsl:attribute>
                <xsl:attribute name="Version"><xsl:value-of select="Version"/></xsl:attribute>
                <xsl:attribute name="Code"><xsl:value-of select="Code"/></xsl:attribute>
              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>