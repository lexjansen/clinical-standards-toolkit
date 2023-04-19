<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

  <xsl:import href="ItemRangeCheckValues.xsl"/>

	<xsl:template name="ItemRangeChecks">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../ItemRangeChecks[FK_ItemDefs = $parentKey]">      
              <xsl:element name="RangeCheck">
                <xsl:attribute name="Comparator"><xsl:value-of select="Comparator"/></xsl:attribute>
                <xsl:attribute name="SoftHard"><xsl:value-of select="SoftHard"/></xsl:attribute>
                <xsl:attribute name="def:ItemOID"><xsl:value-of select="FK_ItemDefs"/></xsl:attribute>
                
                <xsl:call-template name="ItemRangeCheckValues">
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template> 

                  <xsl:call-template name="FormalExpression">
                    <xsl:with-param name="parent">ItemRangeChecks</xsl:with-param>
                    <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                  </xsl:call-template>

                
                <xsl:if test="string-length(normalize-space(MURefOID)) &gt; 0">
                   <xsl:element name="MeasurementUnitRef">
                      <xsl:attribute name="MeasurementUnitOID"><xsl:value-of select="MURefOID"/></xsl:attribute>
                   </xsl:element>
                </xsl:if>

              	<xsl:variable name="RangeCheckOID"><xsl:value-of select="OID"/></xsl:variable>
              		<xsl:variable name="ItemOriginOID"><xsl:value-of select="OID"/></xsl:variable>
              		<xsl:if test="count(../TranslatedText[parent = 'ItemRangeChecks' and parentKey = $RangeCheckOID]) &gt; 0">
              			<xsl:element name="ErrorMessage">
              		    <xsl:call-template name="TranslatedText">
              		  	  <xsl:with-param name="parent">ItemRangeChecks</xsl:with-param>
              	  		  <xsl:with-param name="parentKey"><xsl:value-of select="$RangeCheckOID"/></xsl:with-param>
              		    </xsl:call-template>
              	    </xsl:element>
              		</xsl:if>	
       
              	
              </xsl:element>        
          </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>