<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:import href="MeasurementUnits.xsl" />
    <xsl:import href="MetaDataVersion.xsl" />
    <xsl:import href="TranslatedText.xsl" />

	<xsl:template match="odm:Study">
          
          <xsl:element name="Study">
            <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
            <xsl:element name="StudyName"><xsl:value-of select="odm:GlobalVariables/odm:StudyName"/></xsl:element> 
            <xsl:element name="StudyDescription"><xsl:value-of select="odm:GlobalVariables/odm:StudyDescription"/></xsl:element> 
            <xsl:element name="ProtocolName"><xsl:value-of select="odm:GlobalVariables/odm:ProtocolName"/></xsl:element>
            <xsl:element name="FK_DefineDocument"><xsl:value-of select="../@FileOID"/></xsl:element>
          </xsl:element>
     
          <xsl:call-template name="MeasurementUnits"/>
          <xsl:call-template name="MetaDataVersion"/>

  </xsl:template>
</xsl:stylesheet>