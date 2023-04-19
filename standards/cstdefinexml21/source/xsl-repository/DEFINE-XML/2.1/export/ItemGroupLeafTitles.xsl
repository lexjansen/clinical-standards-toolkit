<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemGroupLeafTitles">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../ItemGroupLeafTitles[FK_ItemGroupLeaf = $parentKey]">
       
          <xsl:element name="def:title">
            <xsl:value-of select="title"/>
          </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>