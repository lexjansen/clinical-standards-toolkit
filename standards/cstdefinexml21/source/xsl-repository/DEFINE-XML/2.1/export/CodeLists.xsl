<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">
        
    <xsl:import href="ExternalCodeLists.xsl"/>   
    <xsl:import href="EnumeratedItems.xsl"/>  
    <xsl:import href="CodeListItems.xsl"/>  
            
	<xsl:template name="CodeLists">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../CodeLists[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="CodeList">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
            <xsl:attribute name="DataType"><xsl:value-of select="DataType"/></xsl:attribute>            
            <xsl:if test="string-length(normalize-space(IsNonStandard)) &gt; 0">
              <xsl:attribute name="def:IsNonStandard"><xsl:value-of select="IsNonStandard"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(StandardOID)) &gt; 0">
              <xsl:attribute name="def:StandardOID"><xsl:value-of select="StandardOID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(SASFormatName)) &gt; 0">
              <xsl:attribute name="SASFormatName"><xsl:value-of select="SASFormatName"/></xsl:attribute>
            </xsl:if>
           <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
             <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
           </xsl:if>               
           
           <xsl:variable name="OID" select="OID"/>
           
           <xsl:if test="string-length(normalize-space(../TranslatedText[parent = 'CodeLists'  and parentKey = $OID]/TranslatedText)) &gt; 0">
           <xsl:element name="Description">
             <xsl:call-template name="TranslatedText">
               <xsl:with-param name="parent">CodeLists</xsl:with-param>
               <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
             </xsl:call-template>
           </xsl:element> 
           </xsl:if>

           <xsl:call-template name="ExternalCodeLists">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
            
            <xsl:call-template name="EnumeratedItems">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>       
            
            <xsl:call-template name="CodeListItems">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>       

           <xsl:call-template name="Alias">
             <xsl:with-param name="parent">CodeLists</xsl:with-param>
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>
           
         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>