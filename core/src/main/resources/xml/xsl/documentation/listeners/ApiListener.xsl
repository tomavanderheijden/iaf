<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="listener[@className='nl.nn.adapterframework.http.rest.ApiListener']">
		<xsl:variable name="consumes">
			<xsl:choose>
				<xsl:when test="@consumes"><xsl:value-of select="@consumes"/></xsl:when>
				<xsl:otherwise>*/*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="produces">
			<xsl:choose>
				<xsl:when test="@produces"><xsl:value-of select="@produces"/></xsl:when>
				<xsl:otherwise>*/*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li>Listens for <i><xsl:value-of select="@method"/></i> messages at URI pattern <i>/<xsl:value-of select="@uriPattern"/></i></li>
		<li>Input format is <i><xsl:value-of select="$consumes"/></i></li>
		<li>Output format is <i><xsl:value-of select="$produces"/></i></li>
	</xsl:template>
	
</xsl:stylesheet>