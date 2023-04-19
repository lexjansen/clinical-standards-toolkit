<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

 	<xsl:template name="MeasurementUnits">

      <xsl:param name="parentKey" />

<!--  If there are no measurement units, we shouldn't output the BasicDefinitionsElement -->
      
      <xsl:if test="count(../MeasurementUnits[FK_Study = $parentKey]) != 0">
      
       <xsl:element name="BasicDefinitions">
       
         <xsl:for-each select="../MeasurementUnits[FK_Study = $parentKey]">
       
          <xsl:element name="MeasurementUnit">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
 
          	<xsl:element name="Symbol">
          		<xsl:call-template name="TranslatedText">
          			<xsl:with-param name="parent">MeasurementUnits</xsl:with-param>
          			<xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
          		</xsl:call-template>
          	</xsl:element> 
          	
            <xsl:call-template name="Alias">
              <xsl:with-param name="parent">MeasurementUnits</xsl:with-param>
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            
           </xsl:element>
        
         </xsl:for-each>
      
       </xsl:element>
       
     </xsl:if>
        	
  </xsl:template>
</xsl:stylesheet>