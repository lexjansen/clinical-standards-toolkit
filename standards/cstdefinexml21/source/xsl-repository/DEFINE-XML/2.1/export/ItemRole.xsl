<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="ItemRole">
	
	  <xsl:param name="parentKey" />
	  
          <xsl:for-each select="../ItemRole[FK_ItemDefs = $parentKey]">      
              <xsl:element name="Role">
                <xsl:value-of select="Name"/>
              </xsl:element>        
         </xsl:for-each>
        	
  </xsl:template>
</xsl:stylesheet>