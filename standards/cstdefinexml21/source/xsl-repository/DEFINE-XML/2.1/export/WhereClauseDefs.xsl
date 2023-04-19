<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:import href="WhereClauseRangeChecks.xsl"/>
        
	<xsl:template name="WhereClauseDefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../WhereClauseDefs[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="def:WhereClauseDef">

            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
              <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
            </xsl:if> 

            <xsl:call-template name="WhereClauseRangeChecks">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>

         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>