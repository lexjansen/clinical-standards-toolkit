<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arm="http://www.cdisc.org/ns/arm/v1.0">

  <xsl:template name="Standards">
	
	  <xsl:param name="parentKey" />
       
	  <xsl:if test="../Standards[FK_MetaDataVersion = $parentKey]">
  	  <xsl:element name="def:Standards">
  	    <xsl:for-each select="../Standards[FK_MetaDataVersion = $parentKey]">      
         
  	         <xsl:element name="def:Standard">
               <xsl:attribute name="OID"><xsl:value-of select="OID"/></xsl:attribute>
  	           <xsl:attribute name="Name"><xsl:value-of select="Name"/></xsl:attribute>
  	           <xsl:attribute name="Type"><xsl:value-of select="Type"/></xsl:attribute>
  	           
  	           <xsl:if test="string-length(normalize-space(PublishingSet)) &gt; 0">
  	             <xsl:attribute name="PublishingSet"><xsl:value-of select="PublishingSet"/></xsl:attribute>
  	           </xsl:if>
  	           
  	           <xsl:attribute name="Version"><xsl:value-of select="Version"/></xsl:attribute>
  	           <xsl:attribute name="Status"><xsl:value-of select="Status"/></xsl:attribute>

  	           <xsl:if test="string-length(normalize-space(CommentOID)) &gt; 0">
  	             <xsl:attribute name="def:CommentOID"><xsl:value-of select="CommentOID"/></xsl:attribute>
  	           </xsl:if>

  	         </xsl:element>
          
         </xsl:for-each>
  	  </xsl:element>
	  </xsl:if>
       	
  </xsl:template>
</xsl:stylesheet>