<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

    <xsl:import href="Standards.xsl"/>
    <xsl:import href="AnnotatedCRFs.xsl"/>
    <xsl:import href="SupplementalDocs.xsl"/>
    <xsl:import href="ValueLists.xsl"/>
    <xsl:import href="WhereClauseDefs.xsl" />
    <xsl:import href="ProtocolEventRefs.xsl"/>
    <xsl:import href="StudyEventDefs.xsl"/>
    <xsl:import href="FormDefs.xsl"/>
    <xsl:import href="ItemGroupDefs.xsl"/>
    <xsl:import href="ItemDefs.xsl"/>
    <xsl:import href="CodeLists.xsl"/>
    <xsl:import href="ImputationMethods.xsl"/>
    <xsl:import href="Presentation.xsl"/>
	  <xsl:import href="ConditionDefs.xsl"/>
    <xsl:import href="MethodDefs.xsl"/>
    <xsl:import href="CommentDefs.xsl"/>
    <xsl:import href="MDVLeaf.xsl"/>   
    <xsl:import href="AnalysisResultDisplays.xsl"/>   
      
	<xsl:template name="MetaDataVersion">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../MetaDataVersion[FK_Study = $parentKey]">
       
          <xsl:element name="MetaDataVersion">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(Description)) &gt; 0">
               <xsl:attribute name="Description"><xsl:value-of select="Description"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(DefineVersion)) &gt; 0">
              <xsl:attribute name="def:DefineVersion"><xsl:value-of select="DefineVersion"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
              <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
            </xsl:if>
            
            <xsl:call-template name="Standards">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="AnnotatedCRFs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="SupplementalDocs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="ValueLists">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="WhereClauseDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>

            <!-- Include is a subelement. Both attrs are required -->
            <xsl:if test="string-length(normalize-space(IncludedOID)) &gt; 0 or string-length(normalize-space(IncludedStudyOID)) &gt; 0">
               <xsl:element name="Include">
                  <xsl:attribute name="StudyOID"><xsl:value-of select="IncludedStudyOID"/></xsl:attribute>
                  <xsl:attribute name="MetaDataVersionOID"><xsl:value-of select="IncludedOID"/></xsl:attribute>
               </xsl:element>
            </xsl:if>
           
            <xsl:call-template name="ProtocolEventRefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="StudyEventDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="FormDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="ItemGroupDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="ItemDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="CodeLists">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="ImputationMethods">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="Presentation">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
          	<xsl:call-template name="ConditionDefs">
          		<xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
          	</xsl:call-template>
            <xsl:call-template name="MethodDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="CommentDefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="MDVLeaf">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="AnalysisResultDisplays">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            
           </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
 
</xsl:stylesheet>