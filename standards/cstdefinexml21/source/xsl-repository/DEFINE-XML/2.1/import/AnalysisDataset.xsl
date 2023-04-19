<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisWhereClauseRefs.xsl" />
  <xsl:import href="AnalysisVariables.xsl" />
  
  <xsl:template name="AnalysisDataset">	
    
    <xsl:for-each select=".">

      <xsl:element name="AnalysisDataset">
        <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element> 
        <xsl:element name="ItemGroupOID"><xsl:value-of select="@ItemGroupOID"/></xsl:element> 
        <xsl:element name="FK_AnalysisDatasets"><xsl:value-of select="generate-id(..)"/></xsl:element> 
        
      </xsl:element>
      
      <xsl:for-each select="def:WhereClauseRef">
        <xsl:call-template name="AnalysisWhereClauseRefs"/>
      </xsl:for-each>
      
      <xsl:for-each select="arm:AnalysisVariable">
        <xsl:call-template name="AnalysisVariables"/>
      </xsl:for-each>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>