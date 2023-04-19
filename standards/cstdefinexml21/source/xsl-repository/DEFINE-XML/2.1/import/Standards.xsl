<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

  <xsl:template name="Standards">	
    
	  <xsl:for-each select="def:Standards/def:Standard">

	    <xsl:element name="Standards">
        <xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
	      <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
	      <xsl:element name="Type"><xsl:value-of select="@Type"/></xsl:element> 
	      <xsl:element name="PublishingSet"><xsl:value-of select="@PublishingSet"/></xsl:element> 
	      <xsl:element name="Version"><xsl:value-of select="@Version"/></xsl:element> 
	      <xsl:element name="Status"><xsl:value-of select="@Status"/></xsl:element> 
	      <xsl:element name="CommentOID"><xsl:value-of select="@def:CommentOID"/></xsl:element> 
	      <xsl:element name="FK_MetaDataVersion"><xsl:value-of select="../../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
    
	</xsl:template>
</xsl:stylesheet>