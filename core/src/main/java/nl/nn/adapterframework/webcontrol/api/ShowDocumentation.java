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

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.security.RolesAllowed;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import nl.nn.adapterframework.configuration.Configuration;
import nl.nn.adapterframework.core.IAdapter;
import nl.nn.adapterframework.util.XmlUtils;

/**
 * Retrieves the documentation.
 * 
 * @since	7.5
 * @author	Tom van der Heijden
 */

@Path("/")
public final class ShowDocumentation extends Base {

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
		StringWriter writer = new StringWriter();
        StreamResult outputTarget = new StreamResult(writer);
        
		try {
			TransformerFactory factory = TransformerFactory.newInstance();
			Transformer transformer = factory.newTransformer(new StreamSource(this.getClass().getClassLoader().getResourceAsStream("xml/xsl/createDocumentation.xsl")));
			Source xmlSource = XmlUtils.stringToSource(getIbisManager().getConfiguration(configurationName).getRegisteredAdapter(adapterName).getAdapterConfigurationAsString());
            transformer.transform(xmlSource, outputTarget);
			return Response.status(Response.Status.OK).entity(writer.toString()).build();
		} catch (Exception e) {
			return Response.status(Response.Status.OK).entity("ERROR: could not get adapter! " + e).build();
		}
	}	
}
