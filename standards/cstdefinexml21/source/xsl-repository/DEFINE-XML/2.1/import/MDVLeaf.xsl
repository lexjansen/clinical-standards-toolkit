<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:import href="MDVLeafTitles.xsl" />

	<xsl:template name="MDVLeaf">	
    
    <xsl:for-each select="def:leaf">

      <xsl:element name="MDVLeaf">
         <xsl:element name="ID"><xsl:value-of select="@ID"/></xsl:element> 
         <xsl:element name="href"><xsl:value-of select="@xlink:href"/></xsl:element>
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
      
    <xsl:for-each select="def:leaf/def:title">  
      <xsl:call-template name="MDVLeafTitles"/>
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>