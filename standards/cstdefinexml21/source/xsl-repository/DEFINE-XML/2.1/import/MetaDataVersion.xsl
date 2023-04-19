<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

    <xsl:import href="Standards.xsl" />
    <xsl:import href="AnnotatedCRFs.xsl" />
    <xsl:import href="SupplementalDocs.xsl" />
    <xsl:import href="ValueLists.xsl" />
    <xsl:import href="WhereClauseDefs.xsl" />
    <xsl:import href="ProtocolEventRefs.xsl" />
    <xsl:import href="StudyEventDefs.xsl" />
    <xsl:import href="FormDefs.xsl" />
    <xsl:import href="ItemGroupDefs.xsl" />
    <xsl:import href="ItemDefs.xsl" />
    <xsl:import href="CodeLists.xsl" />
    <xsl:import href="ExternalCodeLists.xsl" />
    <xsl:import href="EnumeratedItems.xsl" />
    <xsl:import href="CodeListItems.xsl" />
    <xsl:import href="ImputationMethods.xsl" />
    <xsl:import href="Presentation.xsl" />
	  <xsl:import href="ConditionDefs.xsl" />
    <xsl:import href="MethodDefs.xsl" />
    <xsl:import href="CommentDefs.xsl"/>
    <xsl:import href="MDVLeaf.xsl" />
	  <xsl:import href="TranslatedText.xsl" />
	  <xsl:import href="FormalExpression.xsl" />
  	<xsl:import href="Alias.xsl"/>
	  <xsl:import href="DocumentRefs.xsl"/>
    <xsl:import href="PDFPageRefs.xsl"/>
    <xsl:import href="AnalysisResultDisplays.xsl"/>
  	
	<xsl:template name="MetaDataVersion">	
    
    <xsl:for-each select="odm:MetaDataVersion">

      <xsl:element name="MetaDataVersion">
         <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
         <xsl:element name="Description"><xsl:value-of select="@Description"/></xsl:element> 
         <xsl:element name="IncludedOID"><xsl:value-of select="odm:Include/@MetaDataVersionOID"/></xsl:element>
         <xsl:element name="IncludedStudyOID"><xsl:value-of select="odm:Include/@StudyOID"/></xsl:element>
         <xsl:element name="DefineVersion"><xsl:value-of select="@def:DefineVersion"/></xsl:element>
         <xsl:element name="CommentOID"><xsl:value-of select="@def:CommentOID"/></xsl:element> 
         <xsl:element name="FK_Study"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
      <xsl:call-template name="Standards"/>
      <xsl:call-template name="AnnotatedCRFs"/>
      <xsl:call-template name="SupplementalDocs"/>
      <xsl:call-template name="ValueLists"/>
      <xsl:call-template name="WhereClauseDefs"/>
      <xsl:call-template name="ProtocolEventRefs"/>
      <xsl:call-template name="StudyEventDefs"/>
      <xsl:call-template name="FormDefs"/>
      <xsl:call-template name="ItemGroupDefs"/>
      <xsl:call-template name="ItemDefs"/>
      <xsl:call-template name="CodeLists"/>
      <xsl:call-template name="MDVLeaf"/>
      <xsl:call-template name="AnalysisResultDisplays"/>
      
    </xsl:for-each>
    
    <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:ExternalCodeList">
      <xsl:call-template name="ExternalCodeLists"/>
    </xsl:for-each>
    
		<xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:EnumeratedItem">
			<xsl:call-template name="EnumeratedItems"/>
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:CodeListItem">
			<xsl:call-template name="CodeListItems"/>
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:ImputationMethod">
      <xsl:call-template name="ImputationMethods"/>
    </xsl:for-each>
    
		<xsl:for-each select="odm:MetaDataVersion/odm:Presentation">
			<xsl:call-template name="Presentation"/>
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:ConditionDef">
			<xsl:call-template name="ConditionDefs"/>
		</xsl:for-each>
		
	  <xsl:for-each select="odm:MetaDataVersion/odm:MethodDef">
	    <xsl:call-template name="MethodDefs"/>
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/def:CommentDef">
	    <xsl:call-template name="CommentDefs"/>
	  </xsl:for-each>
	  
	  
		<xsl:for-each select="odm:BasicDefinitions/odm:MeasurementUnit/odm:Symbol/odm:TranslatedText">
			<xsl:call-template name="TranslatedText">
				<xsl:with-param name="parent">MeasurementUnits</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:Protocol/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">MetaDataVersion</xsl:with-param>
      	<xsl:with-param name="parentKey"><xsl:value-of select="../../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:StudyEventDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">StudyEventDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:FormDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">FormDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/def:ValueListDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">ValueLists</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:ItemGroupDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">ItemGroupDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

		<xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/odm:Description/odm:TranslatedText">
			<xsl:call-template name="TranslatedText">
				<xsl:with-param name="parent">ItemDefs</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/odm:Question/odm:TranslatedText">
			<xsl:call-template name="TranslatedText">
				<xsl:with-param name="parent">ItemQuestion</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/def:Origin/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">ItemOrigin</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/odm:RangeCheck/odm:ErrorMessage/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">ItemRangeChecks</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">CodeLists</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:CodeListItem/odm:Decode/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">CodeListItems</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:CodeListItem/odm:Description/odm:TranslatedText">
	    <xsl:call-template name="TranslatedText">
	      <xsl:with-param name="parent">CodeListItemDescription</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:EnumeratedItem/odm:Description/odm:TranslatedText">
	    <xsl:call-template name="TranslatedText">
	      <xsl:with-param name="parent">EnumeratedItemDescription</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ConditionDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">ConditionDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/odm:MethodDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">MethodDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

    <xsl:for-each select="odm:MetaDataVersion/def:CommentDef/odm:Description/odm:TranslatedText">
      <xsl:call-template name="TranslatedText">
        <xsl:with-param name="parent">CommentDefs</xsl:with-param>
        <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>

	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/odm:Description/odm:TranslatedText">
	    <xsl:call-template name="TranslatedText">
	      <xsl:with-param name="parent">AnalysisResultDisplays</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/odm:Description/odm:TranslatedText">
	    <xsl:call-template name="TranslatedText">
	      <xsl:with-param name="parent">AnalysisResults</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/arm:Documentation/odm:Description/odm:TranslatedText">
	    <xsl:call-template name="TranslatedText">
	      <xsl:with-param name="parent">AnalysisDocumentation</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(../..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/odm:RangeCheck/odm:FormalExpression">
			<xsl:call-template name="FormalExpression">
				<xsl:with-param name="parent">ItemRangeChecks</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>

		<xsl:for-each select="odm:MetaDataVersion/odm:ConditionDef/odm:FormalExpression">
			<xsl:call-template name="FormalExpression">
				<xsl:with-param name="parent">ConditionDefs</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:MethodDef/odm:FormalExpression">
			<xsl:call-template name="FormalExpression">
				<xsl:with-param name="parent">MethodDefs</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
	  <xsl:for-each select="odm:BasicDefinitions/odm:MeasurementUnit/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">MeasurementUnits</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>

	  <xsl:for-each select="odm:MetaDataVersion/odm:Protocol/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">MetaDataVersion</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>

	  <xsl:for-each select="odm:MetaDataVersion/odm:StudyEventDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">StudyEventDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:FormDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">FormDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ItemGroupDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">ItemGroupDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">ItemDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">CodeLists</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:CodeListItem/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">CodeListItems</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:CodeList/odm:EnumeratedItem/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">EnumeratedItems</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:MethodDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">MethodDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ConditionDef/odm:Alias">
	    <xsl:call-template name="Alias">
	      <xsl:with-param name="parent">ConditionDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>

		<xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/def:Origin/def:DocumentRef">
			<xsl:call-template name="DocumentRefs">
				<xsl:with-param name="parent">ItemOrigin</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:MethodDef/def:DocumentRef">
			<xsl:call-template name="DocumentRefs">
				<xsl:with-param name="parent">MethodDefs</xsl:with-param>
				<xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
			</xsl:call-template>  
		</xsl:for-each>
		
	  <xsl:for-each select="odm:MetaDataVersion/def:CommentDef/def:DocumentRef">
	    <xsl:call-template name="DocumentRefs">
	      <xsl:with-param name="parent">CommentDefs</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/def:DocumentRef">
	    <xsl:call-template name="DocumentRefs">
	      <xsl:with-param name="parent">AnalysisResultDisplays</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="../@OID"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/arm:Documentation/def:DocumentRef">
	    <xsl:call-template name="DocumentRefs">
	      <xsl:with-param name="parent">AnalysisDocumentation</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/arm:ProgrammingCode/def:DocumentRef">
	    <xsl:call-template name="DocumentRefs">
	      <xsl:with-param name="parent">AnalysisProgrammingCode</xsl:with-param>
	      <xsl:with-param name="parentKey"><xsl:value-of select="generate-id(..)"/></xsl:with-param>
	    </xsl:call-template>  
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/odm:ItemDef/def:Origin/def:DocumentRef/def:PDFPageRef">
			<xsl:call-template name="PDFPageRefs" />
		</xsl:for-each>
		
		<xsl:for-each select="odm:MetaDataVersion/odm:MethodDef/def:DocumentRef/def:PDFPageRef">
			<xsl:call-template name="PDFPageRefs" />
		</xsl:for-each>
		
	  <xsl:for-each select="odm:MetaDataVersion/def:CommentDef/def:DocumentRef/def:PDFPageRef">
	    <xsl:call-template name="PDFPageRefs" />
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/def:DocumentRef/def:PDFPageRef">
	    <xsl:call-template name="PDFPageRefs" />
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/arm:Documentation/def:DocumentRef/def:PDFPageRef">
	    <xsl:call-template name="PDFPageRefs" />
	  </xsl:for-each>
	  
	  <xsl:for-each select="odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay/arm:AnalysisResult/arm:ProgrammingCode/def:DocumentRef/def:PDFPageRef">
	    <xsl:call-template name="PDFPageRefs" />
	  </xsl:for-each>
	  
	</xsl:template>
</xsl:stylesheet>