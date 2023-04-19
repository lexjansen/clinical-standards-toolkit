<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

    <xsl:import href="WhereClauseRangeChecks.xsl" />
    <xsl:import href="WhereClauseRangeCheckValues.xsl" />

	<xsl:template name="WhereClauseDefs">	
    
    <xsl:for-each select="def:WhereClauseDef">

      <xsl:element name="WhereClauseDefs">
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
         <xsl:element name="CommentOID"><xsl:value-of select="@def:CommentOID"/></xsl:element>
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
    
    <xsl:for-each select="def:WhereClauseDef/odm:RangeCheck">
       <xsl:call-template name="WhereClauseRangeChecks"/>
    </xsl:for-each>
    
    <xsl:for-each select="def:WhereClauseDef/odm:RangeCheck/odm:CheckValue">
       <xsl:call-template name="WhereClauseRangeCheckValues"/>
    </xsl:for-each>

  </xsl:template>
</xsl:stylesheet>