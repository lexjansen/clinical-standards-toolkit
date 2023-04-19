<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:template name="ImputationMethods">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../ImputationMethods[FK_MetaDataVersion = $parentKey]">
       
          <xsl:element name="ImputationMethod">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>           
            <xsl:value-of select="method"/>               
          </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>