<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

 	<xsl:template name="ConditionDefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../ConditionDefs[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="ConditionDef">
            <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>   
            
         	<xsl:element name="Description">
         		<xsl:call-template name="TranslatedText">
         			<xsl:with-param name="parent">ConditionDefs</xsl:with-param>
         			<xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
         		</xsl:call-template>
         	</xsl:element> 

           <xsl:call-template name="FormalExpression">
             <xsl:with-param name="parent">ConditionDefs</xsl:with-param>
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>
           
           <xsl:call-template name="Alias">
             <xsl:with-param name="parent">ConditionDefs</xsl:with-param>
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>

         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>