<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:def="http://www.cdisc.org/ns/def/v2.1"
                xmlns="http://www.cdisc.org/ns/odm/v1.3">

  <xsl:template name="ItemGroupClassSubClass">
    
    <xsl:param name="parentKey" />

    <xsl:for-each select="../ItemGroupClassSubClass[FK_ItemGroupClass = $parentKey]">

    <xsl:element name="def:SubClass">
      
      <xsl:if test="string-length(normalize-space(Name)) &gt; 0">
        <xsl:attribute name="Name">
          <xsl:value-of select="Name"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(normalize-space(ParentClass)) &gt; 0">
        <xsl:attribute name="ParentClass">
          <xsl:value-of select="ParentClass"/>
        </xsl:attribute>
      </xsl:if>

    </xsl:element>
      
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>