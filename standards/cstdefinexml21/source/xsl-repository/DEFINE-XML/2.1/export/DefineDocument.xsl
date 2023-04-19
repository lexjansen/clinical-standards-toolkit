<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
  <xsl:import href="TranslatedText.xsl"/>
  <xsl:import href="Alias.xsl"/>
  <xsl:import href="FormalExpression.xsl"/>
  <xsl:import href="Study.xsl" />
    
	<xsl:template match="/LIBRARY">

    <!--  import stylesheet if desired -->
    <xsl:if test="$stylesheetref.creation = 'true'">
      <xsl:text>
</xsl:text>
      <!-- Xalan has a bug that causes the quoting to be messed up in a PI if you use xsl:text. 
           Therefore, this must stay all on one line, like so: -->
      <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="<xsl:value-of select='$stylesheetref.name'/>"</xsl:processing-instruction>      
    </xsl:if>
    
		<xsl:if test="string-length(normalize-space($header.comment.text)) &gt; 0">
    <xsl:text>
</xsl:text>
    <xsl:comment>
        <xsl:value-of select="$header.comment.text"/>
    </xsl:comment><xsl:text>
</xsl:text>
		</xsl:if>

    <ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"
			xmlns:xlink="http://www.w3.org/1999/xlink"
			xmlns:def="http://www.cdisc.org/ns/def/v2.1">
			
      <xsl:attribute name="FileOID"><xsl:value-of select="DefineDocument/FileOID"/></xsl:attribute>
			<xsl:attribute name="CreationDateTime"><xsl:value-of select="$timestamp.creation"/></xsl:attribute>
			<xsl:if test="string-length(normalize-space(DefineDocument/Archival)) &gt; 0">
			   <xsl:attribute name="Archival"><xsl:value-of select="DefineDocument/Archival"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(normalize-space(DefineDocument/AsOfDateTime)) &gt; 0">
			   <xsl:attribute name="AsOfDateTime"><xsl:value-of select="DefineDocument/AsOfDateTime"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(normalize-space(DefineDocument/Description)) &gt; 0">
			   <xsl:attribute name="Description"><xsl:value-of select="DefineDocument/Description"/></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="FileType"><xsl:value-of select="DefineDocument/FileType"/></xsl:attribute>
			<xsl:if test="string-length(normalize-space(DefineDocument/Granularity)) &gt; 0">
			   <xsl:attribute name="Granularity"><xsl:value-of select="DefineDocument/Granularity"/></xsl:attribute>
			</xsl:if>	
			<xsl:if test="string-length(normalize-space(DefineDocument/Id)) &gt; 0">
			   <xsl:attribute name="Id"><xsl:value-of select="DefineDocument/Id"/></xsl:attribute>
			</xsl:if>		
			<xsl:if test="string-length(normalize-space(DefineDocument/ODMVersion)) &gt; 0">
			   <xsl:attribute name="ODMVersion"><xsl:value-of select="DefineDocument/ODMVersion"/></xsl:attribute>
			</xsl:if>				
			<xsl:if test="string-length(normalize-space(DefineDocument/Originator)) &gt; 0">
			   <xsl:attribute name="Originator"><xsl:value-of select="DefineDocument/Originator"/></xsl:attribute>
			</xsl:if>			
			<xsl:if test="string-length(normalize-space(DefineDocument/PriorFileOID)) &gt; 0">
			   <xsl:attribute name="PriorFileOID"><xsl:value-of select="DefineDocument/PriorFileOID"/></xsl:attribute>
			</xsl:if>			
			<xsl:if test="string-length(normalize-space(DefineDocument/SourceSystem)) &gt; 0">
			   <xsl:attribute name="SourceSystem"><xsl:value-of select="DefineDocument/SourceSystem"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(normalize-space(DefineDocument/SourceSystemVersion)) &gt; 0">
			   <xsl:attribute name="SourceSystemVersion"><xsl:value-of select="DefineDocument/SourceSystemVersion"/></xsl:attribute>
			</xsl:if>	
			<xsl:if test="string-length(normalize-space(DefineDocument/Context)) &gt; 0">
			   <xsl:attribute name="def:Context"><xsl:value-of select="DefineDocument/Context"/></xsl:attribute>
			</xsl:if>	
    
		 <xsl:call-template name="Study"/>
		
	</ODM>
		
	</xsl:template>
	
</xsl:stylesheet>