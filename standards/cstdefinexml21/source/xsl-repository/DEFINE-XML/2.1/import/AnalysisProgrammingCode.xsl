<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:template name="AnalysisProgrammingCode">	
    
    <xsl:for-each select=".">

      <xsl:variable name="str" select="arm:Code"/>


      <xsl:element name="AnalysisProgrammingCode">
        <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element> 
        <xsl:element name="Context"><xsl:value-of select="@Context"/></xsl:element> 
        <xsl:element name="Code">
        <xsl:call-template name="string-replace">
          <xsl:with-param name="string" select="$str"/>
          <xsl:with-param name="from" select="'&#10;'"/>
          <xsl:with-param name="to" select="'\n'"/>
        </xsl:call-template>
        </xsl:element> 
        <xsl:element name="FK_AnalysisResults"><xsl:value-of select="../@OID"/></xsl:element>
      
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