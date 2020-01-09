<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:frank="http://frank"
	version="2.0">
	<xsl:output
		method="html"
		indent="yes" />
		
	<xsl:include href="documentation/index.xsl"/>
		
	<xsl:template match="/">
		<html>
			<head>
				<style> 
					body { 
						font-family: helvetica;
					}
					h1 {
						margin: 60px;
						page-break-after: always;
					}
					h1, h2 {
						text-align: center;
						color: #0768C9;
					}
					.bold {
						font-weight: bold;
					} 
					.chapter { 
		                margin: auto;
		                width: 750px;
		            }
		            .chapter:not(:last-child) {
		                page-break-after: always;                    
		            }
		            .description { 
		            	text-align: center;
		            	margin: 15px auto 45px;
		            }
		            .flow-step {
		            	margin: 15px 0px;
		            }
				</style>
			</head>
			<body>
				<h1>
					<xsl:value-of select="adapter/@name" />
				</h1>
				<xsl:if test="adapter/@description">
					<div class="description">
						<i><xsl:value-of select="adapter/@description" /></i>				
					</div>
				</xsl:if>
				<h2>Adapter info</h2>
				<div class="chapter">
					<p>
						<xsl:variable name="pipeCount" select="count(adapter/pipeline/pipe)"/>
						<xsl:variable name="receiverCount" select="count(adapter/receiver)"/>

						<xsl:value-of select="adapter/@name" />

						<xsl:text> has </xsl:text>
						<xsl:value-of select="$receiverCount " />
						<xsl:text> receiver</xsl:text>
						<xsl:if test="not($receiverCount  = 1)">
							<xsl:text>s</xsl:text>
						</xsl:if>

						<xsl:text> and </xsl:text>
						<xsl:value-of select="$pipeCount" />
						<xsl:text> pipe</xsl:text>
						<xsl:if test="not($pipeCount = 1)">
							<xsl:text>s</xsl:text>
						</xsl:if>
						
						<xsl:text>.</xsl:text>
					</p>
					<div>
						<xsl:value-of select="adapter/Documentation" disable-output-escaping="yes"/>
					</div>
				</div>
				<h2>Receivers</h2>	
				<div class="chapter">
					<xsl:apply-templates select="adapter/receiver"></xsl:apply-templates>
				</div>
				<h2>Flows</h2>
				<div class="chapter">
					<h3>Flow 1</h3>
					<ol class="flow">
						<li class="flow-step">
							<xsl:text>Receives message from </xsl:text>
							<xsl:value-of select="adapter/receiver[1]/listener/@className"/>
							<xsl:if test="adapter/receiver[1]/Documentation">
								<xsl:apply-templates select="adapter/receiver[1]/Documentation"></xsl:apply-templates>
							</xsl:if>
						</li>
						<xsl:call-template name="forwards">
							<xsl:with-param name="forwardPath">
								<xsl:value-of select="adapter/pipeline/@firstPipe"/>
							</xsl:with-param>
						</xsl:call-template>
					</ol>
				</div>
				<div class="chapter">
					<h3>Flow 2</h3>
					<p>Here will be another flow</p>
				</div>
				<h2>Documents</h2>
				<div class="chapter">
					<xsl:for-each-group select="adapter/pipeline/pipe/@fileName" group-by=".">
						<xsl:call-template name="documents"/>
					</xsl:for-each-group>
					<xsl:for-each-group select="adapter/pipeline/pipe/@styleSheetName" group-by=".">
						<xsl:call-template name="documents"/>
					</xsl:for-each-group>
					<xsl:for-each-group select="adapter/pipeline/pipe/@schema" group-by=".">
						<xsl:call-template name="documents"/>
					</xsl:for-each-group>
					<xsl:for-each-group select="adapter/pipeline/pipe/@serviceSelectionStylesheetFilename" group-by=".">
						<xsl:call-template name="documents"/>
					</xsl:for-each-group>
				</div>
				<h2>Connections</h2>
				<div class="chapter">
					<p>
						<xsl:text>This adapter has </xsl:text>
						<xsl:value-of select="count(adapter/pipeline/pipe/sender)"/>
						<xsl:text> connection</xsl:text>
						<xsl:if test="count(adapter/pipeline/pipe/sender) != 1"> 
							<xsl:text>s</xsl:text>
						</xsl:if>
						<xsl:text>.</xsl:text>
					</p>
					<xsl:if test="adapter/pipeline/pipe/sender">
						<table border="1">
							<tr>
								<th>Sender name</th>
								<th>Connection method</th>
								<th>Location</th>
								<th>Documentation</th>
							</tr>
							<xsl:for-each select="adapter/pipeline/pipe/sender">
								<tr>
									<td>
										<xsl:choose>
											<xsl:when test="@name">
												<xsl:value-of select="@name"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../@name"/>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<td>
										<xsl:value-of select="frank:getLastPartOfClassName(@className)"/>
									</td>
									<td>
										<xsl:if test="@url">
											<xsl:value-of select="@url"/>
										</xsl:if>
										<xsl:if test="@javaListener">
											<xsl:value-of select="@javaListener"/>
										</xsl:if>
										<xsl:if test="@serviceName">
											<xsl:value-of select="@serviceName"/>
										</xsl:if>
										<xsl:if test="@datasourceName">
											<xsl:value-of select="@datasourceName"/>
										</xsl:if>
										<xsl:if test="@jmsRealm">
											<xsl:value-of select="@djmsRealm"/>
										</xsl:if>
									</td>
									<td>
										<xsl:value-of select="Documentation" disable-output-escaping="yes"/>
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</xsl:if>
				</div>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="forwards">
		<xsl:param name="forwardPath"/>
		<xsl:if test="adapter/pipeline/pipe[@name=$forwardPath]/forward[1]/@path">
			<xsl:variable name="pipe" select="adapter/pipeline/pipe[@name=$forwardPath]"/>
			<li class="flow-step">
				<xsl:value-of select="$pipe/@name"/> : <xsl:value-of select="frank:getLastPartOfClassName($pipe/@className)"/>
				<ul class="flow-step-description">
					<xsl:if test="$pipe/@getInputFromSessionKey">
						<li>Reads input from session key <i><xsl:value-of select="$pipe/@getInputFromSessionKey"/></i></li>
					</xsl:if>
					<xsl:apply-templates select="$pipe"></xsl:apply-templates>
					<xsl:if test="$pipe/@storeResultInSessionKey">
						<li>Stores output in session key <i><xsl:value-of select="$pipe/@storeResultInSessionKey"/></i></li>
					</xsl:if>
				</ul>
				<xsl:if test="$pipe/Documentation">
					<xsl:apply-templates select="$pipe/Documentation"></xsl:apply-templates>
				</xsl:if>
			</li>
			<xsl:call-template name="forwards">
				<xsl:with-param name="forwardPath" select="$pipe/forward[1]/@path"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Documentation">
		<i>--Note: <xsl:value-of select="." disable-output-escaping="yes"/></i>
	</xsl:template>

	<xsl:template match="receiver">
		<div>
			<h3><xsl:value-of select="@name"/></h3>
			<p>
				Receives messages over the 
				<xsl:if test="listener/@name">
					<i><xsl:value-of select="listener/@name"/></i>
				</xsl:if> 
				listener which is of type 
				<i><xsl:value-of select="frank:getLastPartOfClassName(listener/@className)"/></i>.
			</p>
			<ul>
				<xsl:apply-templates select="listener"></xsl:apply-templates>
				<xsl:if test="listener/Documentation">
					<li><xsl:apply-templates select="listener/Documentation"></xsl:apply-templates></li> 
				</xsl:if>
			</ul>
			<xsl:if test="messageLog">
				<xsl:call-template name="ReceiverJdbcComponents">
					<xsl:with-param name="jdbcComponent" select="messageLog"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="errorStorage">
				<xsl:call-template name="ReceiverJdbcComponents">
					<xsl:with-param name="jdbcComponent" select="errorStorage"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Documentation">
				<p>
					<xsl:apply-templates select="Documentation"></xsl:apply-templates>
				</p>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="ReceiverJdbcComponents">
		<xsl:param name="jdbcComponent"/>
		<p>Has 
		    <xsl:value-of select="local-name($jdbcComponent)"/> 
		    of type 
			<i><xsl:value-of select="frank:getLastPartOfClassName($jdbcComponent/@className)"/></i> 
			writing to slotId 
			<i><xsl:value-of select="$jdbcComponent/@slotId"/></i> 
			<xsl:choose>
				<xsl:when test="$jdbcComponent/@jmsRealm"> at jmsRealm <i><xsl:value-of select="$jdbcComponent/@jmsRealm"/></i></xsl:when>
				<xsl:otherwise> at datasourceName <i><xsl:value-of select="$jdbcComponent/@datasourceName"/></i></xsl:otherwise>
			</xsl:choose>
		.</p>
	</xsl:template>

	<xsl:template name="documents">
		<p>
			<svg width="32px" height="32px" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" >
			    <title>
			    	<xsl:value-of select="."/>
			    </title>
			    <defs></defs>
			    <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
			        <g id="icon-69-document-text" fill="#000000">
			            <path d="M19,3 L9.0085302,3 C7.8992496,3 7,3.89833832 7,5.00732994 L7,27.9926701 C7,29.1012878 7.89092539,30 8.99742191,30 L24.0025781,30 C25.1057238,30 26,29.1090746 26,28.0025781 L26,11 L21.0059191,11 C19.8980806,11 19,10.1132936 19,9.00189865 L19,3 L19,3 Z M10,6 L10,7 L10,8 L11,8 L11,7 L12,7 L12,11 L13,11 L13,7 L14,7 L14,8 L15,8 L15,7 L15,6 L10,6 L10,6 Z M20,3 L20,8.99707067 C20,9.55097324 20.4509752,10 20.990778,10 L26,10 L20,3 L20,3 Z M10,16 L10,17 L23,17 L23,16 L10,16 L10,16 Z M10,13 L10,14 L23,14 L23,13 L10,13 L10,13 Z M10,19 L10,20 L23,20 L23,19 L10,19 L10,19 Z M10,22 L10,23 L23,23 L23,22 L10,22 L10,22 Z M10,25 L10,26 L23,26 L23,25 L10,25 L10,25 Z" id="document-text"></path>
			        </g>
			    </g>
			</svg>
			<xsl:value-of select="."/>
		</p>
	</xsl:template>
	
	<xsl:function name="frank:getLastPartOfClassName">
	    <xsl:param name="inputString"/>
	    <xsl:value-of select="tokenize($inputString,'\.')[last()]"/>
	</xsl:function>
</xsl:stylesheet>