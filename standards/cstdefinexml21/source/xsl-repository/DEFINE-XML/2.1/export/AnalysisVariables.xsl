<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:template name="AnalysisVariable">
	
	  <xsl:param name="parentKey" />
       
    <xsl:for-each select="../AnalysisVariables[FK_AnalysisDataset = $parentKey]">      
         
      <xsl:element name="arm:AnalysisVariable">
        <xsl:attribute name="ItemOID"><xsl:value-of select="ItemOID"/></xsl:attribute>
     </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>