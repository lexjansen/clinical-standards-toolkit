<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="ItemQuestionExternal">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemQuestionExternal">
         <xsl:element name="Dictionary"><xsl:value-of select="@Dictionary"/></xsl:element> 
         <xsl:element name="Version"><xsl:value-of select="@Version"/></xsl:element>
         <xsl:element name="Code"><xsl:value-of select="@Code"/></xsl:element> 
         <xsl:element name="FK_ItemDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>