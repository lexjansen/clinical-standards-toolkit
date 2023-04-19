<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemRefWhereClauseRefs">
	
	  <xsl:param name="parentKey" />
	  
          <xsl:for-each select="../ItemRefWhereClauseRefs[ValueListItemRefsOID = $parentKey]">      
              <xsl:element name="def:WhereClauseRef">
                <xsl:attribute name="WhereClauseOID"><xsl:value-of select="FK_WhereClauseDefs"/></xsl:attribute>
              </xsl:element>        
         </xsl:for-each>
        	
   </xsl:template>
</xsl:stylesheet>