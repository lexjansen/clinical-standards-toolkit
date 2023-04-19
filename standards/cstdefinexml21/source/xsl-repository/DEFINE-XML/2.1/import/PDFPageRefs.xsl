<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="PDFPageRefs">

		<xsl:for-each select=".">
			<xsl:element name="PDFPageRefs">
				<xsl:element name="PageRefs"><xsl:value-of select="@PageRefs" /></xsl:element>
				<xsl:element name="FirstPage"><xsl:value-of select="@FirstPage" /></xsl:element>
				<xsl:element name="LastPage"><xsl:value-of select="@LastPage" /></xsl:element>
				<xsl:element name="Type"><xsl:value-of select="@Type" /></xsl:element>
				<xsl:element name="Title"><xsl:value-of select="@Title" /></xsl:element>
				<xsl:element name="FK_DocumentRefs"><xsl:value-of select="generate-id(..)" /></xsl:element>
			</xsl:element>
		</xsl:for-each>

	</xsl:template>
</xsl:stylesheet>