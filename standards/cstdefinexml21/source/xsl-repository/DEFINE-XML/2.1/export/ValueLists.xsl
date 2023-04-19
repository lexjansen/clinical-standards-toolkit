<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:import href="ValueListItemRefs.xsl"/>

	<xsl:template name="ValueLists">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../ValueLists[FK_MetaDataVersion = $parentKey]">
       
          <xsl:element name="def:ValueListDef">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>   
            
            <xsl:variable name="OID" select="OID"/>
            
            <xsl:if test="string-length(normalize-space(../TranslatedText[parent = 'ValueLists'  and parentKey = $OID]/TranslatedText)) &gt; 0">
              <xsl:element name="Description">
              <xsl:call-template name="TranslatedText">
                <xsl:with-param name="parent">ValueLists</xsl:with-param>
                <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
              </xsl:call-template>
            </xsl:element> 
            </xsl:if>

            <xsl:call-template name="ValueListItemRefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
                                
          </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>