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


	public void function addPath(required string path, required string method, string summary="", array parameters=[], array tags=[]) {
		param name="variables.paths['#arguments.path#']" default=createObject("java", "java.util.LinkedHashMap").init();

		variables.paths[ arguments.path ][ arguments.method ] = {
			"summary": arguments.summary,
			"parameters": arguments.parameters,
			"tags": arguments.tags
		};
	}


	public struct function generate() {
		var response = {
			"openapi": this.getOpenAPIVersion(),
			"info": new subsystems.openAPI.models.objects.Info( this.getInfo() ).generate(),
			"paths": new subsystems.openAPI.models.objects.Paths( this.getPaths() ).generate()
		};

		return response;
	}
}
