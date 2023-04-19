<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:def="http://www.cdisc.org/ns/def/v2.1"
	xmlns="http://www.cdisc.org/ns/odm/v1.3">

	<xsl:template name="AnnotatedCRFs">
	
	     <xsl:param name="parentKey" />
       
<!--  If there are no Annotated CRFs, we shouldn't output the def:AnnotatedCRF element -->
      
      <xsl:if test="count(../AnnotatedCRFs[FK_MetaDataVersion = $parentKey]) != 0">

          <xsl:element name="def:AnnotatedCRF">
            <xsl:for-each select="../AnnotatedCRFs[FK_MetaDataVersion = $parentKey]">
       
              <xsl:element name="def:DocumentRef">
                 <xsl:attribute name="leafID"><xsl:value-of select="leafID"/></xsl:attribute>
                 <xsl:value-of select="DocumentRef"/>       
              </xsl:element>
        
           </xsl:for-each>
           
          </xsl:element>
       	
     </xsl:if>

  </xsl:template>
</xsl:stylesheet>