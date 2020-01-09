<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="pipe[@className='nl.nn.adapterframework.pipes.ForEachChildElementPipe']">
		<li>Iterates over all children found in when <i><xsl:value-of select="@elementXPathExpression"/></i> is applied to input XML.</li>
	</xsl:template>
	
</xsl:stylesheet>