component accessors="true" {
	property Framework;

	public component function init() {
		return this;
	}


	/**
	 * Generates OpenAPI JSON and displays it with SwaggerUI
	 */
	public void function default(required struct rc) {
		var configArguments = {};
		var beanFactory = variables.Framework.getBeanFactory();
		if (beanFactory.containsBean("OpenAPIConfig")) {
			configArguments.configBean = variables.framework.getBeanFactory().getBean("OpenAPIConfig");
		}

		var generator = new subsystems.openapi.models.OpenAPIGenerator();
		generator.setRoutes( variables.framework.getRoutes() );
		generator.setResourceRouteTemplates( variables.framework.getResourceRouteTemplates() );
		generator.configure(argumentCollection: configArguments);
		rc.spec = generator.run();
	}
}
