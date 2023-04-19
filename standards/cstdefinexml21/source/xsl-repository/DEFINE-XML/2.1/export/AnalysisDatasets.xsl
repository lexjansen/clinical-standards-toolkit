<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisDataset.xsl"/>
  
  <xsl:template name="AnalysisDatasets">
	
	  <xsl:param name="parentKey" />
       
	  <xsl:for-each select="../AnalysisDatasets[FK_AnalysisResults = $parentKey]">      
         
     <xsl:element name="arm:AnalysisDatasets">
       <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
         <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
       </xsl:if>
       
       <xsl:call-template name="AnalysisDataset">
         <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
       </xsl:call-template>
     
     </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>