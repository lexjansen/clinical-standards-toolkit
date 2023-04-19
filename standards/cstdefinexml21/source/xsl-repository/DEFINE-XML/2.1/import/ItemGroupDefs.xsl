<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

  <xsl:import href="ItemGroupItemRefs.xsl" />
  <xsl:import href="ItemGroupClass.xsl" />
  <xsl:import href="ItemGroupLeaf.xsl" />
  <xsl:import href="ItemGroupLeafTitles.xsl" />

	<xsl:template name="ItemGroupDefs">	
    
    <xsl:for-each select="odm:ItemGroupDef">

      <xsl:element name="ItemGroupDefs">
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
         <xsl:element name="Repeating"><xsl:value-of select="@Repeating"/></xsl:element> 
         <xsl:element name="IsReferenceData"><xsl:value-of select="@IsReferenceData"/></xsl:element>
         <xsl:element name="SASDatasetName"><xsl:value-of select="@SASDatasetName"/></xsl:element>
         <xsl:element name="Domain"><xsl:value-of select="@Domain"/></xsl:element>
         <xsl:element name="Origin"><xsl:value-of select="@Origin"/></xsl:element>
         <xsl:element name="Role"><xsl:value-of select="@Role"/></xsl:element>
         <xsl:element name="Purpose"><xsl:value-of select="@Purpose"/></xsl:element>
         <xsl:element name="Comment"><xsl:value-of select="@Comment"/></xsl:element>
         <xsl:element name="Structure"><xsl:value-of select="@def:Structure"/></xsl:element>
         <xsl:element name="CommentOID"><xsl:value-of select="@def:CommentOID"/></xsl:element>
         <xsl:element name="ArchiveLocationID"><xsl:value-of select="@def:ArchiveLocationID"/></xsl:element>
         <xsl:element name="IsNonStandard"><xsl:value-of select="@def:IsNonStandard"/></xsl:element>
         <xsl:element name="StandardOID"><xsl:value-of select="@def:StandardOID"/></xsl:element>
         <xsl:element name="HasNoData"><xsl:value-of select="@def:HasNoData"/></xsl:element>
         <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
    
    <xsl:for-each select="odm:ItemGroupDef/odm:ItemRef">
      <xsl:call-template name="ItemGroupItemRefs"/>
    </xsl:for-each>
    
    <xsl:for-each select="odm:ItemGroupDef/def:Class">
      <xsl:call-template name="ItemGroupClass"/>
    </xsl:for-each>

    <xsl:for-each select="odm:ItemGroupDef/def:leaf">
      <xsl:call-template name="ItemGroupLeaf"/>
    </xsl:for-each>
    
    <xsl:for-each select="odm:ItemGroupDef/def:leaf/def:title">  
      <xsl:call-template name="ItemGroupLeafTitles"/>
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>