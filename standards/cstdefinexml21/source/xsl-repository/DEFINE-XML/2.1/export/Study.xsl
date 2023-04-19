<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:import href="MeasurementUnits.xsl" />
    <xsl:import href="MetaDataVersion.xsl" />

	<xsl:template name="Study">
      
      <xsl:for-each select="Study">
      
          <xsl:element name="Study">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:element name="GlobalVariables">
              <xsl:if test="string-length(normalize-space(StudyName)) &gt; 0">
                <xsl:element name="StudyName"><xsl:value-of select="StudyName"/></xsl:element>
              </xsl:if>
              <xsl:if test="string-length(normalize-space(StudyDescription)) &gt; 0"> 
                <xsl:element name="StudyDescription"><xsl:value-of select="StudyDescription"/></xsl:element> 
              </xsl:if>
              <xsl:if test="string-length(normalize-space(ProtocolName)) &gt; 0">
                <xsl:element name="ProtocolName"><xsl:value-of select="ProtocolName"/></xsl:element>
              </xsl:if>
            </xsl:element>
            
            <xsl:call-template name="MeasurementUnits">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="MetaDataVersion">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            
          </xsl:element>
          
      </xsl:for-each>    
        	
  </xsl:template>
</xsl:stylesheet>