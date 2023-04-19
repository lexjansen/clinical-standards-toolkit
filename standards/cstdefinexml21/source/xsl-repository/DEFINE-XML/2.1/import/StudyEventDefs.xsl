<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

    <xsl:import href="StudyEventFormRefs.xsl" />

	<xsl:template name="StudyEventDefs">	
    
    <xsl:for-each select="odm:StudyEventDef">

      <xsl:element name="StudyEventDefs">
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element> 
         <xsl:element name="Category"><xsl:value-of select="@Category"/></xsl:element> 
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element>
         <xsl:element name="Repeating"><xsl:value-of select="@Repeating"/></xsl:element>
         <xsl:element name="Type"><xsl:value-of select="@Type"/></xsl:element>
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
    
    <xsl:for-each select="odm:StudyEventDef/odm:FormRef">
      <xsl:call-template name="StudyEventFormRefs"/>
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>