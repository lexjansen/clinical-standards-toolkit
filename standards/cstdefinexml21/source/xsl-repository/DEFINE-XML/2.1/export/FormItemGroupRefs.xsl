<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:template name="FormItemGroupRefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../FormItemGroupRefs[FK_FormDefs = $parentKey]">      
       
         <xsl:element name="ItemGroupRef">
               <xsl:attribute name="ItemGroupOID"><xsl:value-of select="ItemGroupOID"/></xsl:attribute>
               <xsl:if test="string-length(normalize-space(OrderNumber)) &gt; 0">
                  <xsl:attribute name="OrderNumber"><xsl:value-of select="OrderNumber"/></xsl:attribute>
               </xsl:if>
               <xsl:attribute name="Mandatory"><xsl:value-of select="Mandatory"/></xsl:attribute>
               <xsl:if test="string-length(normalize-space(CollectionExceptionConditionOID)) &gt; 0">
                   <xsl:attribute name="CollectionExceptionConditionOID"><xsl:value-of select="CollectionExceptionConditionOID"/></xsl:attribute>
               </xsl:if>
         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>