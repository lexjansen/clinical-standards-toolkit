<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisDatasets.xsl"/>
  <xsl:import href="AnalysisDocumentation.xsl"/>
  <xsl:import href="AnalysisProgrammingCode.xsl"/>
  
  <xsl:template name="AnalysisResults">
	
	  <xsl:param name="parentKey" />
       
	  <xsl:for-each select="../AnalysisResults[FK_AnalysisResultDisplays = $parentKey]">      
         
     <xsl:element name="arm:AnalysisResult">
       <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
       <xsl:if test="string-length(normalize-space(ParameterOID)) &gt; 0">
         <xsl:attribute name="ParameterOID"><xsl:value-of select="ParameterOID"/></xsl:attribute>
       </xsl:if>
       <xsl:attribute name="AnalysisReason"><xsl:value-of select="AnalysisReason"/></xsl:attribute>
       <xsl:attribute name="AnalysisPurpose"><xsl:value-of select="AnalysisPurpose"/></xsl:attribute>
       
      <xsl:element name="Description">
        <xsl:call-template name="TranslatedText">
          <xsl:with-param name="parent">AnalysisResults</xsl:with-param>
          <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
        </xsl:call-template>
      </xsl:element> 
    
       <xsl:call-template name="AnalysisDatasets">
         <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="AnalysisDocumentation">
         <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="AnalysisProgrammingCode">
         <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
       </xsl:call-template>
       
     </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>