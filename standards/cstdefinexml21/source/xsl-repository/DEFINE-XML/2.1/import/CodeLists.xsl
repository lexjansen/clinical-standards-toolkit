<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="CodeLists">	
    
    <xsl:for-each select="odm:CodeList">

      <xsl:element name="CodeLists">
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
         <xsl:element name="DataType"><xsl:value-of select="@DataType"/></xsl:element> 
         <xsl:element name="IsNonStandard"><xsl:value-of select="@def:IsNonStandard"/></xsl:element>
         <xsl:element name="StandardOID"><xsl:value-of select="@def:StandardOID"/></xsl:element>
         <xsl:element name="SASFormatName"><xsl:value-of select="@SASFormatName"/></xsl:element>
         <xsl:element name="CommentOID"><xsl:value-of select="@def:CommentOID"/></xsl:element>
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>