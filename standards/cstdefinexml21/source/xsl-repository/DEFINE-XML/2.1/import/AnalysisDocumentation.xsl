<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:template name="AnalysisDocumentation">	
    
    <xsl:for-each select=".">

      <xsl:element name="AnalysisDocumentation">
        <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element> 
        <xsl:element name="FK_AnalysisResults"><xsl:value-of select="../@OID"/></xsl:element>
      
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>