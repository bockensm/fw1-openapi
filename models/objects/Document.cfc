component accessors="true" {
	property openAPIVersion;
	property info;
	property servers;
	property paths;
	property components;
	property security;
	property tags;
	property externalDocs;

	public component function init() {
		this.setOpenAPIVersion("3.0.2");
		this.setPaths( createObject("java", "java.util.LinkedHashMap").init() );

		return this;
	}


	public void function addPath(required string path, required string method, string summary="", array parameters=[], struct responses={}, struct requestBody={}, array tags=[]) {
		param name="variables.paths['#arguments.path#']" default=createObject("java", "java.util.LinkedHashMap").init();

		variables.paths[ arguments.path ][ arguments.method ] = {
			"summary": arguments.summary,
			"parameters": arguments.parameters,
			"responses": arguments.responses,
			"tags": arguments.tags
		};

		if (!structIsEmpty(arguments.requestBody)) {
			variables.paths[ arguments.path ][ arguments.method ][ "requestBody" ] = arguments.requestBody;
		}
	}


	public struct function generate() {
		var response = {
			"openapi": this.getOpenAPIVersion(),
			"info": new subsystems.openapi.models.objects.Info( this.getInfo() ).generate(),
			"paths": new subsystems.openapi.models.objects.Paths( this.getPaths() ).generate(),
			"components": this.getComponents()
		};

		return response;
	}
}
