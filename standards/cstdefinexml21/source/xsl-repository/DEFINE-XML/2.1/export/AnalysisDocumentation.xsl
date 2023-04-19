<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisDataset.xsl"/>
  
  <xsl:template name="AnalysisDocumentation">
	
	  <xsl:param name="parentKey" />
       
	  <xsl:for-each select="../AnalysisDocumentation[FK_AnalysisResults = $parentKey]">      
         
	    <xsl:element name="arm:Documentation">
     
	      <xsl:element name="Description">
	        <xsl:call-template name="TranslatedText">
	          <xsl:with-param name="parent">AnalysisDocumentation</xsl:with-param>
	          <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	        </xsl:call-template>
	      </xsl:element> 

	      <xsl:variable name="DocumentationOID"><xsl:value-of select="OID"/></xsl:variable>
	      <xsl:if test="count(../DocumentRefs[parent = 'AnalysisDocumentation' and parentKey = $DocumentationOID]) &gt; 0">
	        <xsl:call-template name="DocumentRefs">
	          <xsl:with-param name="parent">AnalysisDocumentation</xsl:with-param>
	          <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	        </xsl:call-template>
	      </xsl:if>

	    </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>