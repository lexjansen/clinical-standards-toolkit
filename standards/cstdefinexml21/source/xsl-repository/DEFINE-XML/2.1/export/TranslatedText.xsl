<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:template name="TranslatedText">

    	<xsl:param name="parent" />
    	<xsl:param name="parentKey" />
    	
            <xsl:choose>
            	<xsl:when test="count(../TranslatedText[parent = $parent and parentKey = $parentKey]) &gt; 0">

                	<xsl:for-each select="(../TranslatedText[parent = $parent  and parentKey = $parentKey])">

                	  <xsl:if test="string-length(normalize-space(TranslatedText)) &gt; 0">
                	    <xsl:element name="TranslatedText">
                        <xsl:if test="string-length(normalize-space(lang)) &gt; 0">
                          <xsl:attribute name="xml:lang">
                        	  <xsl:value-of select="lang" />
                          </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="TranslatedText" />
                      </xsl:element>
                	  </xsl:if>
                  </xsl:for-each>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="TranslatedText" />
                </xsl:otherwise>
            </xsl:choose>

    </xsl:template>
</xsl:stylesheet>