<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="DocumentRefs">
	  
	  <xsl:param name="parent" />
	  <xsl:param name="parentKey" />

		<xsl:for-each select=".">
			
			<xsl:element name="DocumentRefs">
				<xsl:element name="OID"><xsl:value-of select="generate-id(.)"/></xsl:element>
				<xsl:element name="leafID"><xsl:value-of select="@leafID"/></xsl:element>
				<xsl:element name="parent"><xsl:value-of select="$parent"/></xsl:element>
				<xsl:element name="parentKey"><xsl:value-of select="$parentKey"/></xsl:element>
			</xsl:element>
			
		</xsl:for-each>

	</xsl:template>
</xsl:stylesheet>