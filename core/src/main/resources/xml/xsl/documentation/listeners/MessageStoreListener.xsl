<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	
	<xsl:template match="listener[@className='nl.nn.adapterframework.jdbc.MessageStoreListener']">
		<li>Listens for messages in messagestore with slotId <i><xsl:value-of select="@slotId"/></i> at jmsRealm <i><xsl:value-of select="@jmsRealm"/></i></li>
	</xsl:template>
	
</xsl:stylesheet>