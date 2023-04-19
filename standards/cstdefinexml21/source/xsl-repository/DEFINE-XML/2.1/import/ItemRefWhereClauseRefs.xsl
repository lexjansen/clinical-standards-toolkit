<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="ItemRefWhereClauseRefs">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemRefWhereClauseRefs">
         <xsl:element name="ValueListItemRefsOID"><xsl:value-of select="generate-id(..)"/></xsl:element> 
         <xsl:element name="FK_WhereClauseDefs"><xsl:value-of select="@WhereClauseOID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>