<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemRangeCheckValues">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../ItemRangeCheckValues[FK_ItemRangeChecks = $parentKey]">      
              <xsl:element name="CheckValue">
                <xsl:value-of select="CheckValue"/>
              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>