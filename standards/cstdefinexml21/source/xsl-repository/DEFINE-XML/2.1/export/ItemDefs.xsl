<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:import href="ItemQuestionExternal.xsl"/>
    <xsl:import href="ItemMURefs.xsl"/>
    <xsl:import href="ItemRangeChecks.xsl"/>
    <xsl:import href="ItemRole.xsl"/>
    <xsl:import href="ItemOrigin.xsl"/>
    <xsl:import href="ItemValueListRefs.xsl"/>
        
	<xsl:template name="ItemDefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../ItemDefs[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="ItemDef">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
            <xsl:attribute name="DataType"><xsl:value-of select="DataType"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(Length)) &gt; 0">
               <xsl:attribute name="Length"><xsl:value-of select="Length"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(SignificantDigits)) &gt; 0">
               <xsl:attribute name="SignificantDigits"><xsl:value-of select="SignificantDigits"/></xsl:attribute>
            </xsl:if>            
            <xsl:if test="string-length(normalize-space(SASFieldName)) &gt; 0">
              <xsl:attribute name="SASFieldName"><xsl:value-of select="SASFieldName"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(SDSVarName)) &gt; 0">
              <xsl:attribute name="SDSVarName"><xsl:value-of select="SDSVarName"/></xsl:attribute>
            </xsl:if>            
            <xsl:if test="string-length(normalize-space(Origin)) &gt; 0">
              <xsl:attribute name="Origin"><xsl:value-of select="Origin"/></xsl:attribute>
            </xsl:if>        
            <xsl:if test="string-length(normalize-space(Comment)) &gt; 0">
              <xsl:attribute name="Comment"><xsl:value-of select="Comment"/></xsl:attribute>
            </xsl:if> 
            <xsl:if test="string-length(normalize-space(DisplayFormat)) &gt; 0">
              <xsl:attribute name="def:DisplayFormat"><xsl:value-of select="DisplayFormat"/></xsl:attribute>
            </xsl:if> 
            <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
              <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
            </xsl:if>               
 
            <xsl:variable name="OID" select="OID"/>
           
            <xsl:if test="string-length(normalize-space(../TranslatedText[parent = 'ItemDefs'  and parentKey = $OID]/TranslatedText)) &gt; 0">
              <xsl:element name="Description">
                <xsl:call-template name="TranslatedText">
                  <xsl:with-param name="parent">ItemDefs</xsl:with-param>
                  <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
                </xsl:call-template>
              </xsl:element> 
            </xsl:if>

           	<xsl:variable name="ItemOID"><xsl:value-of select="OID"/></xsl:variable>
           	<xsl:if test="count(../TranslatedText[parent = 'ItemQuestion' and parentKey = $ItemOID]) &gt; 0">
	         		<xsl:element name="Question">
	         				<xsl:call-template name="TranslatedText">
	         					<xsl:with-param name="parent">ItemQuestion</xsl:with-param>
	         					<xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	         				</xsl:call-template>
	         		</xsl:element>
	         	</xsl:if>
	         	
	         	<xsl:call-template name="ItemQuestionExternal">
	              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	            </xsl:call-template>
	            <xsl:call-template name="ItemMURefs">
	              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	            </xsl:call-template>
	            <xsl:call-template name="ItemRangeChecks">
	              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	            </xsl:call-template>
	            <xsl:if test="string-length(normalize-space(CodeListRef)) &gt; 0">
	              <xsl:element name="CodeListRef">
	                 <xsl:attribute name="CodeListOID"><xsl:value-of select="CodeListRef"/></xsl:attribute>
	              </xsl:element>
	            </xsl:if>
	            <xsl:call-template name="ItemRole">
	              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	            </xsl:call-template>
	 
	           <xsl:call-template name="Alias">
	             <xsl:with-param name="parent">ItemDefs</xsl:with-param>
	             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
	           </xsl:call-template>

           <xsl:call-template name="ItemOrigin">
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>
           
           <xsl:call-template name="ItemValueListRefs">
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>
           
         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>