<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="listener[@className='nl.nn.adapterframework.receivers.JavaListener']">
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>unknown</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li>Listens for messages over java with name <i><xsl:value-of select="@name"/></i>.</li>
		<xsl:if test="@serviceName">
			<li>With the service name <i><xsl:value-of select="@serviceName"/></i>.</li>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>