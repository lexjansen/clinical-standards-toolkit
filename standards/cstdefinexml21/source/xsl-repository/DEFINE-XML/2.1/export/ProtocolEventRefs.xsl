<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ProtocolEventRefs">
	
	   <xsl:param name="parentKey" />
       
       
		<xsl:if test="count(../ProtocolEventRefs[FK_MetaDataVersion = $parentKey]) &gt; 0">
         <xsl:element name="Protocol">
          
            <xsl:element name="Description">
                   <xsl:call-template name="TranslatedText">
                 	  <xsl:with-param name="parent">MetaDataVersion</xsl:with-param>
                   	<xsl:with-param name="parentKey"><xsl:value-of select="$parentKey"/></xsl:with-param>
                 </xsl:call-template>
            </xsl:element> 
          

           <xsl:for-each select="../ProtocolEventRefs[FK_MetaDataVersion = $parentKey]">      
             
           <xsl:element name="StudyEventRef">
               <xsl:attribute name="StudyEventOID"><xsl:value-of select="StudyEventOID"/></xsl:attribute> 
               <xsl:if test="string-length(normalize-space(OrderNumber)) &gt; 0">
                  <xsl:attribute name="OrderNumber"><xsl:value-of select="OrderNumber"/></xsl:attribute>
               </xsl:if>
               <xsl:attribute name="Mandatory"><xsl:value-of select="Mandatory"/></xsl:attribute>
               <xsl:if test="string-length(normalize-space(CollectionExceptionConditionOID)) &gt; 0">
                   <xsl:attribute name="CollectionExceptionConditionOID"><xsl:value-of select="CollectionExceptionConditionOID"/></xsl:attribute>
               </xsl:if>
            </xsl:element>

           </xsl:for-each>

             <xsl:call-template name="Alias">
               <xsl:with-param name="parent">MetaDataVersion</xsl:with-param>
               <xsl:with-param name="parentKey"><xsl:value-of select="$parentKey"/></xsl:with-param>
             </xsl:call-template>

           
         </xsl:element>
		</xsl:if>     
       	
  </xsl:template>
</xsl:stylesheet>