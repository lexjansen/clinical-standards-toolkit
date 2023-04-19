<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

  <xsl:import href="ItemGroupClassSubClass.xsl"/>

	<xsl:template name="ItemGroupClass">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../ItemGroupClass[FK_ItemGroupDefs = $parentKey]">      
       
         <xsl:element name="def:Class">
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
            
            <xsl:call-template name="ItemGroupClassSubClass" >
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
                        
         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>