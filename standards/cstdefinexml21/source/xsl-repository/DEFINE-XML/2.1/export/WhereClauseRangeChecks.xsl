<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:import href="WhereClauseRangeCheckValues.xsl"/>

	<xsl:template name="WhereClauseRangeChecks">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../WhereClauseRangeChecks[FK_WhereClauseDefs = $parentKey]">      
              <xsl:element name="RangeCheck">
                <xsl:attribute name="Comparator"><xsl:value-of select="Comparator"/></xsl:attribute>
                <xsl:attribute name="SoftHard"><xsl:value-of select="SoftHard"/></xsl:attribute>
                <xsl:attribute name="def:ItemOID"><xsl:value-of select="ItemOID"/></xsl:attribute>
                
                <xsl:call-template name="WhereClauseRangeCheckValues">
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template> 

              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>