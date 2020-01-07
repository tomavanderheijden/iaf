/*
Copyright 2016-2017 Integration Partners B.V.

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
package nl.nn.adapterframework.webcontrol.api;

import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.security.RolesAllowed;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import nl.nn.adapterframework.configuration.Configuration;
import nl.nn.adapterframework.configuration.ConfigurationException;
import nl.nn.adapterframework.core.IAdapter;
import nl.nn.adapterframework.stream.Message;
import nl.nn.adapterframework.stream.MessageOutputStream;
import nl.nn.adapterframework.stream.MessageOutputStreamCap;
import nl.nn.adapterframework.stream.StreamingException;
import nl.nn.adapterframework.util.XmlUtils;
import nl.nn.adapterframework.xml.TransformerFilter;
import nl.nn.adapterframework.xml.XmlWriter;
import nl.nn.adapterframework.util.TransformerPool;

/**
 * Retrieves the documentation.
 * 
 * @since	7.5
 * @author	Tom van der Heijden
 */

@Path("/")
public final class ShowDocumentation extends Base {
	private String styleSheetName = "xml/xsl/createDocumentation.xsl";
	
	private TransformerPool transformerPool;
	
	public ShowDocumentation() {
		try {
			transformerPool = TransformerPool.configureTransformer0(null, this.getClass().getClassLoader(), null, null, styleSheetName, null, false, null, 0);
		} catch (ConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@GET
	@RolesAllowed({"IbisObserver", "IbisDataAdmin", "IbisAdmin", "IbisTester"})
	@Path("/documentation/configurations")
	@Relation("documentation")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getDocumentationConfigurations() {
		List<String> list = new ArrayList<>();
		
		for (Configuration configuration : getIbisManager().getConfigurations()) {
			list.add(configuration.getName());
		}
		
		return Response.status(Response.Status.OK).entity(list).build();
	}
	
	@GET
	@RolesAllowed({"IbisObserver", "IbisDataAdmin", "IbisAdmin", "IbisTester"})
	@Path("/documentation/configurations/{configuration}/adapters")
	@Relation("documentation")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getDocumentationConfigurationAdapters(@PathParam("configuration") String configurationName) {
		List<String> list = new ArrayList<>();
		
		for (IAdapter adapter : getIbisManager().getConfiguration(configurationName).getRegisteredAdapters()) {
			list.add(adapter.getName());
		}
		
		return Response.status(Response.Status.OK).entity(list).build();
	}
	
	@GET
	@RolesAllowed({"IbisObserver", "IbisDataAdmin", "IbisAdmin", "IbisTester"})
	@Path("/documentation/configurations/{configuration}/adapters/{adapter}")
	@Relation("documentation")
	@Produces(MediaType.TEXT_HTML)
	public Response getDocumentationConfigurationAdapter(@PathParam("configuration") String configurationName, @PathParam("adapter") String adapterName) {
		try {
			transformerPool.open();
			
			MessageOutputStream target = new MessageOutputStreamCap();
			Message message = new Message(getIbisManager().getConfiguration(configurationName).getRegisteredAdapter(adapterName).getAdapterConfigurationAsString());
			ContentHandler handler = createHandler(message, target);
			InputSource source = message.asInputSource();
			XMLReader reader = XmlUtils.getXMLReader(true, false, handler);
			reader.parse(source);
			
			transformerPool.close();
			
			return Response.status(Response.Status.OK).entity(target.getResponse().toString()).build();
		} catch (Exception e) {
			return Response.status(Response.Status.OK).entity("ERROR: could not get adapter! " + e).build();
		}
	}	

	
	private ContentHandler createHandler(Message input, MessageOutputStream target) throws StreamingException {
		ContentHandler handler = null;

		try {
			TransformerPool poolToUse = transformerPool;
			String outputType = "xml";
			Object targetStream = target.asNative();		
			
			if (targetStream instanceof ContentHandler) {
				handler = (ContentHandler)targetStream;
			} else {
				XmlWriter xmlWriter = new XmlWriter(target.asWriter());
				if ("xml".equals(outputType)) {			
					Boolean omitXmlDeclaration = poolToUse.getOmitXmlDeclaration();
					if (omitXmlDeclaration == null) {
						omitXmlDeclaration = false;
					}
					
					xmlWriter.setIncludeXmlDeclaration(!omitXmlDeclaration);
				} 
				handler = xmlWriter;
			}
			
			TransformerFilter mainFilter = poolToUse.getTransformerFilter(null, null, null, false);
			XmlUtils.setTransformerParameters(mainFilter.getTransformer(),null);
			mainFilter.setContentHandler(handler);
			handler = mainFilter;
	
			return handler;
		} catch (Exception e) {
			log.warn("intermediate exception logging",e);
			
			return null;
		} 
	}

}
