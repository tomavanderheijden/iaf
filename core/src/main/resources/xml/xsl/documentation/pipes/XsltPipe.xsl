<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="pipe[@className='nl.nn.adapterframework.pipes.XsltPipe']">
		<li>
            <xsl:choose>
                <xsl:when test="@styleSheetName">Performs an XSL transformation using <i><xsl:value-of select="@styleSheetName"/></i>.</xsl:when>
                <xsl:when test="@styleSheetNameSessionKey">Performs an XSL transformation reading it's associated stylesheet from session key <i><xsl:value-of select="@styleSheetNameSessionKey"/></i>.</xsl:when>
                <xsl:otherwise>Executes the following xpath expression <i><xsl:value-of select="@xpathExpression"/></i>.</xsl:otherwise>
            </xsl:choose>
        </li>
	</xsl:template>
	
</xsl:stylesheet>