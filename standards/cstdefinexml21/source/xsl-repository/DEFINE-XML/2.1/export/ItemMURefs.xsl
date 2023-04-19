<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemMURefs">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../ItemMURefs[FK_ItemDefs = $parentKey]">      
              <xsl:element name="MeasurementUnitRef">
                <xsl:attribute name="MeasurementUnitOID"><xsl:value-of select="MeasurementUnitOID"/></xsl:attribute>
              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>