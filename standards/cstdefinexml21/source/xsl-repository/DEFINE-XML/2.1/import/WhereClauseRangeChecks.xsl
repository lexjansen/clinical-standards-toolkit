<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="WhereClauseRangeChecks">	
    
    <xsl:for-each select=".">

      <xsl:element name="WhereClauseRangeChecks">
         <!--  Generating an OID so we have something to act as a primary key in the table -->
         <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
         <xsl:element name="Comparator"><xsl:value-of select="@Comparator"/></xsl:element> 
         <xsl:element name="SoftHard"><xsl:value-of select="@SoftHard"/></xsl:element>
         <xsl:element name="ItemOID"><xsl:value-of select="@def:ItemOID"/></xsl:element>
         <xsl:element name="FK_WhereClauseDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>