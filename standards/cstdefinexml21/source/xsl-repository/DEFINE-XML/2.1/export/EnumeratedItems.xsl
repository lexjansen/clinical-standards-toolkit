<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="EnumeratedItems">

	  <xsl:param name="parentKey" />
          <xsl:for-each select="../EnumeratedItems[FK_CodeLists = $parentKey]">  
              
              <xsl:element name="EnumeratedItem">
                 <xsl:attribute name="CodedValue"><xsl:value-of select="CodedValue"/></xsl:attribute>
	             <xsl:if test="string-length(normalize-space(Rank)) &gt; 0">
	                 <xsl:attribute name="Rank"><xsl:value-of select="Rank" /></xsl:attribute>
              </xsl:if>
               <xsl:if test="string-length(normalize-space(OrderNumber)) &gt; 0">
                   <xsl:attribute name="OrderNumber"><xsl:value-of select="OrderNumber"/></xsl:attribute>
               </xsl:if>
               <xsl:if test="string-length(normalize-space(ExtendedValue)) &gt; 0">
                   <xsl:attribute name="def:ExtendedValue"><xsl:value-of select="ExtendedValue"/></xsl:attribute>
               </xsl:if>

                <xsl:call-template name="Alias">
                  <xsl:with-param name="parent">EnumeratedItems</xsl:with-param>
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template>

                <xsl:variable name="OID" select="OID"/>
                 
                <xsl:if test="string-length(normalize-space(../TranslatedText[parent = 'EnumeratedItemDescription'  and parentKey = $OID]/TranslatedText)) &gt; 0">
                  <xsl:element name="Description">
                    <xsl:call-template name="TranslatedText">
                      <xsl:with-param name="parent">EnumeratedItemDescription</xsl:with-param>
                      <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                    </xsl:call-template>
                  </xsl:element> 
                </xsl:if>

              </xsl:element>        
              
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>