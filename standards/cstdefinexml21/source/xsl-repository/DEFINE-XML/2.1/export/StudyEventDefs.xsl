<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:import href="StudyEventFormRefs.xsl"/>

	<xsl:template name="StudyEventDefs">
	
	   <xsl:param name="parentKey" />
       
       <xsl:for-each select="../StudyEventDefs[FK_MetaDataVersion = $parentKey]">      
       
         <xsl:element name="StudyEventDef">
               <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
               <xsl:if test="string-length(normalize-space(Category)) &gt; 0">
                  <xsl:attribute name="Category"><xsl:value-of select="Category"/></xsl:attribute>
               </xsl:if>
               <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
               <xsl:attribute name="Repeating"><xsl:value-of select="Repeating"/></xsl:attribute>
               <xsl:if test="string-length(normalize-space(Type)) &gt; 0">
                 <xsl:attribute name="Type"><xsl:value-of select="Type"/></xsl:attribute>
               </xsl:if>
         
           <xsl:element name="Description">
             <xsl:call-template name="TranslatedText">
               <xsl:with-param name="parent">StudyEventDefs</xsl:with-param>
               <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
             </xsl:call-template>
           </xsl:element> 

           <xsl:call-template name="StudyEventFormRefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>
         
           <xsl:call-template name="Alias">
             <xsl:with-param name="parent">StudyEventDefs</xsl:with-param>
             <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
           </xsl:call-template>

         </xsl:element>
        
       </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>