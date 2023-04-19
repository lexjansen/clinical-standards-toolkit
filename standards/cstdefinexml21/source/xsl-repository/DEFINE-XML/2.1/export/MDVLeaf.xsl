<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"	
	xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:import href="MDVLeafTitles.xsl"/>

	<xsl:template name="MDVLeaf">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../MDVLeaf[FK_MetaDataVersion = $parentKey]">
       
          <xsl:element name="def:leaf">
            <xsl:attribute name="ID"><xsl:value-of select="ID"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(href)) &gt; 0">
               <xsl:attribute name="xlink:href"><xsl:value-of select="href"/></xsl:attribute>
            </xsl:if> 
            
            <xsl:call-template name="MDVLeafTitles">
              <xsl:with-param name="parentKey"><xsl:value-of select="ID"/></xsl:with-param>
            </xsl:call-template>
                
          </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>