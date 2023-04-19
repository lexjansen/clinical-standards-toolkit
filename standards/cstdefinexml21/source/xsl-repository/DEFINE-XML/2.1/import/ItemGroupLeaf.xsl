<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:template name="ItemGroupLeaf">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemGroupLeaf">
         <xsl:element name="ID"><xsl:value-of select="@ID"/></xsl:element> 
         <xsl:element name="href"><xsl:value-of select="@xlink:href"/></xsl:element>
         <xsl:element name="FK_ItemGroupDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>