<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="StudyEventFormRefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../StudyEventFormRefs[FK_StudyEventDefs = $parentKey]">      
       
         <xsl:element name="FormRef">
               <xsl:attribute name="FormOID"><xsl:value-of select="FormOID"/></xsl:attribute>
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