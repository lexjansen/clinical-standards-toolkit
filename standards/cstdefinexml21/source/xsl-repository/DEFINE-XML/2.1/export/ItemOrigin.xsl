<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

<xsl:include href="DocumentRefs.xsl"/>

	<xsl:template name="ItemOrigin">
	
	  <xsl:param name="parentKey" />
	  
          <xsl:for-each select="../ItemOrigin[FK_ItemDefs = $parentKey]">      
              <xsl:element name="def:Origin">

                <xsl:attribute name="Type"><xsl:value-of select="Type"/></xsl:attribute>
                <xsl:if test="string-length(normalize-space(Source)) &gt; 0">
                  <xsl:attribute name="Source"><xsl:value-of select="Source"/></xsl:attribute>
                </xsl:if> 
                <xsl:variable name="ItemOriginOID"><xsl:value-of select="OID"/></xsl:variable>
                <xsl:if test="count(../TranslatedText[parent = 'ItemOrigin' and parentKey = $ItemOriginOID]) &gt; 0">
                <xsl:element name="Description">
                  <xsl:call-template name="TranslatedText">
                    <xsl:with-param name="parent">ItemOrigin</xsl:with-param>
                    <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                  </xsl:call-template>
                </xsl:element> 
                </xsl:if>

                
                <xsl:if test="count(../DocumentRefs[parent = 'ItemOrigin' and parentKey = $ItemOriginOID]) &gt; 0">
                    <xsl:call-template name="DocumentRefs">
                      <xsl:with-param name="parent">ItemOrigin</xsl:with-param>
                      <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                

              </xsl:element> 
                 
         </xsl:for-each>
        	
   </xsl:template>
</xsl:stylesheet>