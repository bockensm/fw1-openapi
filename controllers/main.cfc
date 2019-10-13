component accessors="true" {
	property Framework;

	public component function init() {
		return this;
	}


	/**
	 * Generates OpenAPI JSON and displays it with SwaggerUI
	 */
	public void function default(required struct rc) {
		var generator = new subsystems.openAPI.models.OpenAPIGenerator();
		generator.setRoutes( variables.framework.getRoutes() );
		generator.configure({});
		rc.spec = generator.run();
	}
}
