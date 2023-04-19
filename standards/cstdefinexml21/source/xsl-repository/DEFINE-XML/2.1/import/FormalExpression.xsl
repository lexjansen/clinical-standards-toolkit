<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="FormalExpression">
	  
	  <xsl:param name="parent" />
	  <xsl:param name="parentKey" />

		<xsl:for-each select=".">
			<xsl:element name="FormalExpressions">
				<xsl:element name="Expression">
					<xsl:value-of select="." />
				</xsl:element>
				<xsl:element name="Context">
					<xsl:value-of select="@Context" />
				</xsl:element>
				<xsl:element name="parent">
					<xsl:value-of select="$parent"/>
				</xsl:element>
				<xsl:element name="parentKey">
					<xsl:value-of select="$parentKey"/>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>

	</xsl:template>
</xsl:stylesheet>