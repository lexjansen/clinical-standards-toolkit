<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

  <xsl:import href="ItemRefWhereClauseRefs.xsl" />

	<xsl:template name="ValueListItemRefs">	
    
    <xsl:for-each select=".">

      <xsl:element name="ValueListItemRefs">
         <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
         <xsl:element name="ItemOID"><xsl:value-of select="@ItemOID"/></xsl:element> 
         <xsl:element name="OrderNumber"><xsl:value-of select="@OrderNumber"/></xsl:element>
         <xsl:element name="Mandatory"><xsl:value-of select="@Mandatory"/></xsl:element> 
         <xsl:element name="KeySequence"><xsl:value-of select="@KeySequence"/></xsl:element>         
         <xsl:element name="ImputationMethodOID"><xsl:value-of select="@ImputationMethodOID"/></xsl:element>
         <xsl:element name="MethodOID"><xsl:value-of select="@MethodOID"/></xsl:element>
         <xsl:element name="Role"><xsl:value-of select="@Role"/></xsl:element>
         <xsl:element name="RoleCodeListOID"><xsl:value-of select="@RoleCodeListOID"/></xsl:element>
         <xsl:element name="HasNoData"><xsl:value-of select="@def:HasNoData"/></xsl:element>
         <xsl:element name="CollectionExceptionConditionOID"><xsl:value-of select="@CollectionExceptionConditionOID"/></xsl:element>      
         <xsl:element name="FK_ValueLists"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>

      <xsl:for-each select="def:WhereClauseRef">
         <xsl:call-template name="ItemRefWhereClauseRefs"/>
      </xsl:for-each>
           	
    </xsl:for-each>
       	
  </xsl:template>
</xsl:stylesheet>