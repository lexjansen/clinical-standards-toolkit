<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:import href="ItemGroupItemRefs.xsl"/>
  <xsl:import href="ItemGroupClass.xsl"/>
  <xsl:import href="ItemGroupLeaf.xsl"/>

	<xsl:template name="ItemGroupDefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../ItemGroupDefs[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="ItemGroupDef">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
            <xsl:attribute name="Repeating"><xsl:value-of select="Repeating"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(IsReferenceData)) &gt; 0">
              <xsl:attribute name="IsReferenceData"><xsl:value-of select="IsReferenceData"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(SASDatasetName)) &gt; 0">
              <xsl:attribute name="SASDatasetName"><xsl:value-of select="SASDatasetName"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Domain)) &gt; 0">
              <xsl:attribute name="Domain"><xsl:value-of select="Domain"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Origin)) &gt; 0">
              <xsl:attribute name="Origin"><xsl:value-of select="Origin"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Role)) &gt; 0">
              <xsl:attribute name="Role"><xsl:value-of select="Role"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Purpose)) &gt; 0">
              <xsl:attribute name="Purpose"><xsl:value-of select="Purpose"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Comment)) &gt; 0">
              <xsl:attribute name="Comment"><xsl:value-of select="Comment"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Structure)) &gt; 0">
              <xsl:attribute name="def:Structure"><xsl:value-of select="Structure"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
              <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(ArchiveLocationID)) &gt; 0">
              <xsl:attribute name="def:ArchiveLocationID"><xsl:value-of select="ArchiveLocationID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(IsNonStandard)) &gt; 0">
              <xsl:attribute name="def:IsNonStandard"><xsl:value-of select="IsNonStandard"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(StandardOID)) &gt; 0">
              <xsl:attribute name="def:StandardOID"><xsl:value-of select="StandardOID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(HasNoData)) &gt; 0">
              <xsl:attribute name="def:HasNoData"><xsl:value-of select="HasNoData"/></xsl:attribute>
            </xsl:if>

            <xsl:variable name="OID" select="OID"/>
           
            <xsl:if test="string-length(normalize-space(../TranslatedText[parent = 'ItemGroupDefs'  and parentKey = $OID]/TranslatedText)) &gt; 0">
              <xsl:element name="Description">
                <xsl:call-template name="TranslatedText">
                  <xsl:with-param name="parent">ItemGroupDefs</xsl:with-param>
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template>
              </xsl:element>
            </xsl:if> 
            
            <xsl:call-template name="ItemGroupItemRefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>

           <xsl:call-template name="Alias">
             <xsl:with-param name="parent">ItemGroupDefs</xsl:with-param>
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>
           
            <xsl:call-template name="ItemGroupClass">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template> 

            <xsl:call-template name="ItemGroupLeaf">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template> 
            
         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>