<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisResults.xsl"/>
  
  <xsl:template name="AnalysisResultDisplays">
	
	  <xsl:param name="parentKey" />
       
	  <xsl:if test="../AnalysisResultDisplays[FK_MetaDataVersion = $parentKey]">
  	  <xsl:element name="arm:AnalysisResultDisplays">
  	    <xsl:for-each select="../AnalysisResultDisplays[FK_MetaDataVersion = $parentKey]">      
         
  	         <xsl:element name="arm:ResultDisplay">
              <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
              <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
   
              <xsl:element name="Description">
                <xsl:call-template name="TranslatedText">
                  <xsl:with-param name="parent">AnalysisResultDisplays</xsl:with-param>
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template>
              </xsl:element> 
  
  	           <xsl:variable name="ResultOID"><xsl:value-of select="OID"/></xsl:variable>
  	           <xsl:if test="count(../DocumentRefs[parent = 'AnalysisResultDisplays' and parentKey = $ResultOID]) &gt; 0">
  	             <xsl:call-template name="DocumentRefs">
  	               <xsl:with-param name="parent">AnalysisResultDisplays</xsl:with-param>
  	               <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
  	             </xsl:call-template>
  	           </xsl:if>
  	           
             
  	           <xsl:call-template name="AnalysisResults">
  	             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
  	           </xsl:call-template>
  	         
  	         </xsl:element>
          
         </xsl:for-each>
  	  </xsl:element>
	  </xsl:if>
       	
  </xsl:template>
</xsl:stylesheet>