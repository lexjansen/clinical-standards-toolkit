<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

    <xsl:import href="FormItemGroupRefs.xsl" />
    <xsl:import href="FormArchLayouts.xsl" />

	<xsl:template name="FormDefs">	
    
    <xsl:for-each select="odm:FormDef">

      <xsl:element name="FormDefs">
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
         <xsl:element name="Repeating"><xsl:value-of select="@Repeating"/></xsl:element> 
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
    
    <xsl:for-each select="odm:FormDef/odm:ItemGroupRef">
      <xsl:call-template name="FormItemGroupRefs"/>
    </xsl:for-each>
    
    <xsl:for-each select="odm:FormDef/odm:ArchiveLayout">
      <xsl:call-template name="FormArchLayouts"/>
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>