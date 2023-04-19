<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:import href="ItemRefWhereClauseRefs.xsl" />

	<xsl:template name="ValueListItemRefs">
	
	     <xsl:param name="parentKey" />
       
         <xsl:for-each select="../ValueListItemRefs[FK_ValueLists = $parentKey]">      
       
          <xsl:element name="ItemRef">
            <xsl:attribute name="ItemOID"><xsl:value-of select="ItemOID"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(OrderNumber)) &gt; 0">
               <xsl:attribute name="OrderNumber"><xsl:value-of select="OrderNumber"/></xsl:attribute>
            </xsl:if>
            <xsl:attribute name="Mandatory"><xsl:value-of select="Mandatory"/></xsl:attribute>
            <xsl:if test="string-length(normalize-space(KeySequence)) &gt; 0">
               <xsl:attribute name="KeySequence"><xsl:value-of select="KeySequence"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(ImputationMethodOID)) &gt; 0">
               <xsl:attribute name="ImputationMethodOID"><xsl:value-of select="ImputationMethodOID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(MethodOID)) &gt; 0">
               <xsl:attribute name="MethodOID"><xsl:value-of select="MethodOID"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Role)) &gt; 0">
               <xsl:attribute name="Role"><xsl:value-of select="Role"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(RoleCodeListOID)) &gt; 0">
               <xsl:attribute name="RoleCodeListOID"><xsl:value-of select="RoleCodeListOID"/></xsl:attribute>                         
            </xsl:if>
            <xsl:if test="string-length(normalize-space(HasNoData)) &gt; 0">
              <xsl:attribute name="def:HasNoData"><xsl:value-of select="HasNoData"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(CollectionExceptionConditionOID)) &gt; 0">
                <xsl:attribute name="CollectionExceptionConditionOID"><xsl:value-of select="CollectionExceptionConditionOID"/></xsl:attribute>
            </xsl:if>

            <xsl:call-template name="ItemRefWhereClauseRefs">
              <xsl:with-param name="parentKey"><xsl:value-of select="OID"/></xsl:with-param>
            </xsl:call-template>

          </xsl:element>
        
         </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>