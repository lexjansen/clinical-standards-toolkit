<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.cdisc.org/ns/odm/v1.3">

    <xsl:template name="FormalExpression">

    	<xsl:param name="parent" />
    	<xsl:param name="parentKey" />
    	
      <xsl:for-each select="(../FormalExpressions[parent = $parent  and parentKey = $parentKey])">

            <xsl:element name="FormalExpression">
              <xsl:if test="string-length(normalize-space(Context)) &gt; 0">
                <xsl:attribute name="Context">
                  <xsl:value-of select="Context" />
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="Expression" />
            </xsl:element>

        </xsl:for-each>


    </xsl:template>
</xsl:stylesheet>