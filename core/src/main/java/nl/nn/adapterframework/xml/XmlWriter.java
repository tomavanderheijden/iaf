/*
   Copyright 2019 Integration Partners

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package nl.nn.adapterframework.xml;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.ext.LexicalHandler;
import org.xml.sax.helpers.DefaultHandler;

import nl.nn.adapterframework.util.LogUtil;
import nl.nn.adapterframework.util.StreamUtil;
import nl.nn.adapterframework.util.XmlUtils;

public class XmlWriter extends DefaultHandler implements LexicalHandler {
	protected Logger log = LogUtil.getLogger(this);
	
	private Writer writer;
	private boolean includeXmlDeclaration=false;
	private boolean newlineAfterXmlDeclaration=false;
	private boolean includeComments=true;
	private boolean textMode=false;
	
	private int elementLevel=0;
	private boolean elementJustStarted;
	private boolean inCdata;
	private StringBuffer firstLevelNamespaceDefinitions=new StringBuffer();
	private StringBuffer namespaceDefinitions=new StringBuffer();
	
	public XmlWriter() {
		writer=new StringWriter();
	}
	
	public XmlWriter(Writer writer) {
		this.writer=writer;
	}
	
	public XmlWriter(OutputStream stream) {
		try {
			this.writer=new OutputStreamWriter(stream,StreamUtil.DEFAULT_INPUT_STREAM_ENCODING);
		} catch (UnsupportedEncodingException e) {
			log.error(e);
		}
	}

	@Override
	public void startDocument() throws SAXException {
		try {
			if (!textMode && includeXmlDeclaration) {
				writer.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
				if (newlineAfterXmlDeclaration) {
					writer.append("\n");
				}
			}
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}


	@Override
	public void endDocument() throws SAXException {
		try {
			writer.flush();
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	private void appendNamespaceMapping(StringBuffer output, String prefix, String uri) {
		output.append(" xmlns");
		if (StringUtils.isNotEmpty(prefix) ) {
			output.append(":").append(prefix);
		}
		output.append("=\"").append(XmlUtils.encodeChars(uri)).append("\"");
	}

	@Override
	public void startPrefixMapping(String prefix, String uri) throws SAXException {
		log.debug("startPrefixMapping ["+prefix+"]=["+uri+"]");
		if (elementLevel==0) {
			appendNamespaceMapping(firstLevelNamespaceDefinitions, prefix, uri);
		} else {
			appendNamespaceMapping(namespaceDefinitions, prefix, uri);
		}
		super.startPrefixMapping(prefix, uri);
	}

	@Override
	public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
		try {
			if (elementJustStarted) {
				writer.append(">");
			}
			writer.append("<"+qName);
			for (int i=0; i<attributes.getLength(); i++) {
				writer.append(" "+attributes.getQName(i)+"=\""+XmlUtils.encodeChars(attributes.getValue(i))+"\"");
			}
			if (elementLevel==0) {
				writer.append(firstLevelNamespaceDefinitions);
			}
			writer.append(namespaceDefinitions);
			namespaceDefinitions.setLength(0);
			elementJustStarted=true;
			elementLevel++;
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void endElement(String uri, String localName, String qName) throws SAXException {
		try {
			elementLevel--;
			if (elementJustStarted) {
				elementJustStarted=false;
				writer.append("/>");
			} else {
				writer.append("</"+qName+">");
			}
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void characters(char[] ch, int start, int length) throws SAXException {
		try {
			if (elementJustStarted) {
				elementJustStarted=false;
				writer.append(">");
			}
			if (textMode) {
				writer.write(ch, start, length);
			} else {
				if (inCdata) {
					writer.append(new String(ch, start, length));
				} else {
					writer.append(XmlUtils.encodeChars(new String(ch, start, length)).replace("&quot;", "\""));
				}
			}
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void comment(char[] ch, int start, int length) throws SAXException {
		try {
			if (includeComments) {
				writer.append("<!--").append(new String(ch, start, length)).append("-->");
			}
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void processingInstruction(String target, String data) throws SAXException {
		try {
			writer.append("<?").append(target).append(" ").append(data).append("?>\n");
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void startDTD(String arg0, String arg1, String arg2) throws SAXException {
//		System.out.println("startDTD");
	}

	@Override
	public void endDTD() throws SAXException {
//		System.out.println("endDTD");
	}

	@Override
	public void startCDATA() throws SAXException {
		try {
			if (elementJustStarted) {
				elementJustStarted=false;
				writer.append(">");
			}
			writer.append("<![CDATA[");
			inCdata=true;
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void endCDATA() throws SAXException {
		try {
			writer.append("]]>");
			inCdata=false;
		} catch (IOException e) {
			throw new SaxException(e);
		}
	}

	@Override
	public void startEntity(String arg0) throws SAXException {
//		System.out.println("startEntity ["+arg0+"]");
	}
	@Override
	public void endEntity(String arg0) throws SAXException {
//		System.out.println("endEntity ["+arg0+"]");
	}

	@Override
	public String toString() {
		return writer.toString();
	}

	
	public void setIncludeXmlDeclaration(boolean includeXmlDeclaration) {
		this.includeXmlDeclaration = includeXmlDeclaration;
	}

	public void setNewlineAfterXmlDeclaration(boolean newlineAfterXmlDeclaration) {
		this.newlineAfterXmlDeclaration = newlineAfterXmlDeclaration;
	}

	public void setIncludeComments(boolean includeComments) {
		this.includeComments = includeComments;
	}

	public void setTextMode(boolean textMode) {
		this.textMode = textMode;
	}


}
