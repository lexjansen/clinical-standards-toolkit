<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemValueListRefs">
	
	  <xsl:param name="parentKey" />
	  
          <xsl:for-each select="../ItemValueListRefs[FK_ItemDefs = $parentKey]">      
              <xsl:element name="def:ValueListRef">
                <xsl:attribute name="ValueListOID"><xsl:value-of select="ValueListOID"/></xsl:attribute>
              </xsl:element>        
         </xsl:for-each>
        	
   </xsl:template>
</xsl:stylesheet>