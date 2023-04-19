<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:import href="ItemGroupClassSubClass.xsl" />
  
  <xsl:template name="ItemGroupClass">	
    
    <xsl:for-each select=".">

      <xsl:element name="ItemGroupClass">
         <xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
         <xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element> 
         <xsl:element name="FK_ItemGroupDefs"><xsl:value-of select="../@OID"/></xsl:element>
      </xsl:element>
      
    </xsl:for-each>
	  
	  <xsl:for-each select="def:SubClass">
	    <xsl:call-template name="ItemGroupClassSubClass"/>
	  </xsl:for-each>
	  
       	
  </xsl:template>
</xsl:stylesheet>