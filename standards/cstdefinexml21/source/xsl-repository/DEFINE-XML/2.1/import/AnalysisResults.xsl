<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisDatasets.xsl" />
  <xsl:import href="AnalysisDocumentation.xsl" />
  <xsl:import href="AnalysisProgrammingCode.xsl" />
  
  <xsl:template name="AnalysisResults">	
    
    <xsl:for-each select=".">

      <xsl:element name="AnalysisResults">
        <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element> 
        <xsl:element name="ParameterOID"><xsl:value-of select="@ParameterOID"/></xsl:element>  
        <xsl:element name="AnalysisReason"><xsl:value-of select="@AnalysisReason"/></xsl:element> 
        <xsl:element name="AnalysisPurpose"><xsl:value-of select="@AnalysisPurpose"/></xsl:element> 
        <xsl:element name="FK_AnalysisResultDisplays"><xsl:value-of select="../@OID"/></xsl:element>
      
      </xsl:element>
      
      <xsl:for-each select="arm:AnalysisDatasets">
        <xsl:call-template name="AnalysisDatasets"/>
      </xsl:for-each>

      <xsl:for-each select="arm:Documentation">
        <xsl:call-template name="AnalysisDocumentation"/>
      </xsl:for-each>
      
      <xsl:for-each select="arm:ProgrammingCode">
        <xsl:call-template name="AnalysisProgrammingCode"/>
      </xsl:for-each>
      

    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>