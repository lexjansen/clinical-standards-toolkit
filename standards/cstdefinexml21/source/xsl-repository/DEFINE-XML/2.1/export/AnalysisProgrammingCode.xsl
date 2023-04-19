<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:import href="AnalysisDataset.xsl"/>
  
  <xsl:template name="AnalysisProgrammingCode">
	
	  <xsl:param name="parentKey" />
       
    <xsl:for-each select="../AnalysisProgrammingCode[FK_AnalysisResults = $parentKey]">      
         
      <xsl:element name="arm:ProgrammingCode">
     
        <xsl:if test="string-length(normalize-space(Context)) &gt; 0">
          <xsl:attribute name="Context"><xsl:value-of select="Context"/></xsl:attribute>
        </xsl:if>
 
        <xsl:variable name="str" select="../AnalysisProgrammingCode[FK_AnalysisResults = $parentKey]/Code"/>

        <xsl:if test="string-length(normalize-space(../AnalysisProgrammingCode[FK_AnalysisResults = $parentKey]/Code)) &gt; 0">
          <xsl:element name="arm:Code">
            <xsl:call-template name="string-replace">
              <xsl:with-param name="string" select="$str"/>
              <xsl:with-param name="from" select="'\n'"/>
              <xsl:with-param name="to"><xsl:text>&#10;</xsl:text></xsl:with-param>
            </xsl:call-template>
          </xsl:element>
        </xsl:if>
 
        <xsl:variable name="ProgrammingOID"><xsl:value-of select="OID"/></xsl:variable>
        <xsl:if test="count(../DocumentRefs[parent = 'AnalysisProgrammingCode' and parentKey = $ProgrammingOID]) &gt; 0">
          <xsl:call-template name="DocumentRefs">
            <xsl:with-param name="parent">AnalysisProgrammingCode</xsl:with-param>
            <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      
      </xsl:element>
    
    </xsl:for-each>
       	
  </xsl:template>

  <!-- replace all occurences of the character(s) `from'
     by  `to' in the string `string'.-->
  <xsl:template name="string-replace" >
    <xsl:param name="string"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($string,$from)">
        <xsl:value-of select="substring-before($string,$from)"/>
        <xsl:copy-of select="$to"/>
        <xsl:call-template name="string-replace">
          <xsl:with-param name="string"
            select="substring-after($string,$from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>