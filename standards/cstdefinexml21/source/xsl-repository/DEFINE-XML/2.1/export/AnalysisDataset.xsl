<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisWhereClauseRefs.xsl"/>
  <xsl:import href="AnalysisVariables.xsl"/>
  
  <xsl:template name="AnalysisDataset">
	
	  <xsl:param name="parentKey" />
       
    <xsl:for-each select="../AnalysisDataset[FK_AnalysisDatasets = $parentKey]">      
         
      <xsl:element name="arm:AnalysisDataset">
        <xsl:attribute name="ItemGroupOID"><xsl:value-of select="ItemGroupOID"/>
      </xsl:attribute>
       
        <xsl:call-template name="AnalysisWhereClauseRefs">
          <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
        </xsl:call-template>
        
        <xsl:call-template name="AnalysisVariable">
          <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
        </xsl:call-template>
        
      </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>