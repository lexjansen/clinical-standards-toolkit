<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="MeasurementUnits">
      
      <xsl:for-each select="odm:BasicDefinitions/odm:MeasurementUnit">
        <xsl:element name="MeasurementUnits">
          <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element> 
          <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element>
          <xsl:element name="FK_Study"><xsl:value-of select="../../@OID"/></xsl:element> 
        </xsl:element>                  
      </xsl:for-each>
      
  </xsl:template>
</xsl:stylesheet>