<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="ItemOrigin">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemOrigin">
         <!--  Generating an OID so we have something to act as a primary key in the table -->
         <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
         <xsl:element name="Type"><xsl:value-of select="@Type"/></xsl:element> 
         <xsl:element name="Source"><xsl:value-of select="@Source"/></xsl:element> 
         <xsl:element name="FK_ItemDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>

  </xsl:template>
</xsl:stylesheet>