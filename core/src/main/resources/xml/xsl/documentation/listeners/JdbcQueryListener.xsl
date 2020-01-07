<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="listener[@className='nl.nn.adapterframework.jdbc.JdbcQueryListener']">
		<li>Listens for messages stored in database with datasourceName <i><xsl:value-of select="@datasourceName"/></i>.</li>
		<li>Listens to the following query <i><xsl:value-of select="@selectQuery"/></i> for messages, identifying them as unique by primary key <i><xsl:value-of select="@keyField"/></i>.</li>
		<li>Executes following query when succesfully proccessed message <i><xsl:value-of select="@updateStatusToProcessedQuery"/></i></li>
		<li>Executes following query when an error occured during processing of message <i><xsl:value-of select="@updateStatusToErrorQuery"/></i></li>
	</xsl:template>
	
</xsl:stylesheet>