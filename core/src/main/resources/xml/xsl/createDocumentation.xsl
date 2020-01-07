<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	<xsl:output
		method="html"
		indent="yes" />
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
					<ol>
						<li>
							<xsl:text>Receives message from </xsl:text>
							<xsl:value-of select="adapter/receiver[1]/listener/@className"/>
							<xsl:if test="count(adapter/receiver[1]/Documentation)>0">
								<xsl:text disable-output-escaping="yes"><![CDATA[<span style="font-style: italic;">]]> --Note: </xsl:text>
								<xsl:value-of select="adapter/receiver[1]/Documentation"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[</span>]]></xsl:text>
							</xsl:if>
						</li>
						<li>
							<xsl:value-of select="adapter/pipeline/@firstPipe"/>
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
					<xsl:if test="count(adapter/pipeline/pipe/sender) > 0">
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
											<xsl:when test="count(@name)=1">
												<xsl:value-of select="@name"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../@name"/>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<td>
										<xsl:value-of select="tokenize(@className,'\.')[last()]"/>
									</td>
									<td>
										<xsl:if test="count(@url)=1">
											<xsl:value-of select="@url"/>
										</xsl:if>
										<xsl:if test="count(@javaListener)=1">
											<xsl:value-of select="@javaListener"/>
										</xsl:if>
										<xsl:if test="count(@serviceName)=1">
											<xsl:value-of select="@serviceName"/>
										</xsl:if>
										<xsl:if test="count(@datasourceName)=1">
											<xsl:value-of select="@datasourceName"/>
										</xsl:if>
										<xsl:if test="count(@jmsRealm)=1">
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
		<xsl:if test="count(adapter/pipeline/pipe[@name=$forwardPath]/forward[1]/@path)>0">
			<li>
				<xsl:value-of select="adapter/pipeline/pipe[@name=$forwardPath]/forward[1]/@path"/>
				<xsl:if test="count(adapter/pipeline/pipe[@name=$forwardPath]/Documentation)>0">
					<xsl:text disable-output-escaping="yes"><![CDATA[<span style="font-style: italic;">]]> --Note: </xsl:text>
					<xsl:value-of select="adapter/pipeline/pipe[@name=$forwardPath]/Documentation" disable-output-escaping="yes"/>
					<xsl:text disable-output-escaping="yes"><![CDATA[</span>]]></xsl:text>
				</xsl:if>
			</li>
			<xsl:call-template name="forwards">
				<xsl:with-param name="forwardPath" select="adapter/pipeline/pipe[@name=$forwardPath]/forward[1]/@path"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="receiver">
		<h3><xsl:value-of select="@name"/></h3>
		<p>
			Receives messages over <i><xsl:value-of select="tokenize(listener/@className,'\.')[last()]"/></i>.	
			<xsl:apply-templates select="listener"></xsl:apply-templates>
		</p>
		<xsl:if test="count(messageLog) > 0">
			<p>Has message log of type <i><xsl:value-of select="tokenize(messageLog/@className,'\.')[last()]"/></i> writing to slotId <i><xsl:value-of select="messageLog/@slotId"/></i>.</p>
		</xsl:if>
		<xsl:if test="count(errorStorage) > 0">
			<p>Has error storage of type <i><xsl:value-of select="tokenize(errorStorage/@className,'\.')[last()]"/></i> writing to slotId <i><xsl:value-of select="errorStorage/@slotId"/></i>.</p>
		</xsl:if>
		<xsl:if test="count(Documentation) > 0">
			<p>
				<xsl:text disable-output-escaping="yes"><![CDATA[<span style="font-style: italic;">]]> --Note: </xsl:text>
				<xsl:value-of select="Documentation"/>
				<xsl:text disable-output-escaping="yes"><![CDATA[</span>]]></xsl:text>
			</p>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="listener">
		<xsl:choose>
			<xsl:when test="@className = 'nl.nn.adapterframework.http.rest.ApiListener'">
				<xsl:variable name="consumes">
					<xsl:choose>
						<xsl:when test="string-length(@consumes) = 0">*/*</xsl:when>
						<xsl:otherwise><xsl:value-of select="@consumes"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="produces">
					<xsl:choose>
						<xsl:when test="string-length(@produces) = 0">*/*</xsl:when>
						<xsl:otherwise><xsl:value-of select="@produces"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<ul>
					<li>Listens for <i><xsl:value-of select="@method"/></i> messages at URI pattern <i>/<xsl:value-of select="@uriPattern"/></i></li>
					<li>Input format is <i><xsl:value-of select="$consumes"/></i></li>
					<li>Output format is <i><xsl:value-of select="$produces"/></i></li>
				</ul>
			</xsl:when>
		</xsl:choose>
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
</xsl:stylesheet>