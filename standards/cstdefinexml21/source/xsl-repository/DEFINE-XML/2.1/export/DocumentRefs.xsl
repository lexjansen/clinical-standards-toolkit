<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:def="http://www.cdisc.org/ns/def/v2.1"
                xmlns="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:import href="PDFPageRefs.xsl"/>

    <xsl:template name="DocumentRefs">

    	<xsl:param name="parent" />
    	<xsl:param name="parentKey" />
    	
          <xsl:if test="count(../DocumentRefs[parent = $parent and parentKey = $parentKey]) &gt; 0">
    
            <xsl:for-each select="(../DocumentRefs[parent = $parent  and parentKey = $parentKey])">
    
                <xsl:element name="def:DocumentRef">
                  <xsl:attribute name="leafID">
                    <xsl:value-of select="leafID" />
                  </xsl:attribute>
    
                  <xsl:variable name="MethodOID"><xsl:value-of select="OID"/></xsl:variable>
                  <xsl:for-each select="(../PDFPageRefs[FK_DocumentRefs = $MethodOID])">
    
                    <xsl:call-template name="PDFPageRefs"/>
    
                  </xsl:for-each>  
                </xsl:element>
    
            </xsl:for-each>
          </xsl:if>

    </xsl:template>
</xsl:stylesheet>