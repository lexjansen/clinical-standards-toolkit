<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="CodeListItems">	
    
    <xsl:for-each select=".">

      <xsl:element name="CodeListItems">
         <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
         <xsl:element name="CodedValue"><xsl:value-of select="@CodedValue"/></xsl:element> 
         <xsl:element name="Rank"><xsl:value-of select="@Rank"/></xsl:element>          
         <xsl:element name="OrderNumber"><xsl:value-of select="@OrderNumber"/></xsl:element>
         <xsl:element name="ExtendedValue"><xsl:value-of select="@def:ExtendedValue"/></xsl:element>          
         <xsl:element name="FK_CodeLists"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>

    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>