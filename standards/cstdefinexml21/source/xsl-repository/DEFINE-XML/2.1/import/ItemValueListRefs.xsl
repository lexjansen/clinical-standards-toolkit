<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="ItemValueListRefs">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemValueListRefs">
         <xsl:element name="ValueListOID"><xsl:value-of select="@ValueListOID"/></xsl:element> 
         <xsl:element name="FK_ItemDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>