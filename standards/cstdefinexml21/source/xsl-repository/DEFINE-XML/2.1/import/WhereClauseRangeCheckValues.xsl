<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1">

	<xsl:template name="WhereClauseRangeCheckValues">

		<xsl:for-each select=".">

			<xsl:element name="WhereClauseRangeCheckValues">
				<xsl:element name="CheckValue">
					<xsl:value-of select="." />
				</xsl:element>
				<xsl:element name="FK_WhereClauseRangeChecks">
				    <!--  The parent OID was generated so we have something to reference as a parent -->
					<xsl:value-of select="generate-id(..)" />
				</xsl:element>
			</xsl:element>

		</xsl:for-each>

	</xsl:template>
</xsl:stylesheet>