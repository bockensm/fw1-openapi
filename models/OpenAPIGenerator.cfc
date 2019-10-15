component accessors="true" {
	property prefixes;
	property routes;
	property resourceRouteTemplates;

	public component function init() {

		return this;
	}


	/**
	 * Configures parts of the OpenAPI spec JSON
	 *
	 * @config Component that contains configuration information
	 */
	public void function configure(component configBean) {
		if (!structKeyExists(arguments, "configBean")) {
			arguments.configBean = new subsystems.openAPI.config.OpenApiConfig();
		}

		variables.info = arguments.configBean.getInfo();
		variables.componentSchemaFolder = arguments.configBean.getComponentSchemaFolder();
		this.setPrefixes( arguments.configBean.getPrefixes() );
	}


	/**
	 * Takes all provided input and returns a structure that
	 * represents an OpenAPI-compatible respresentation of
	 * the declared routes
	 */
	public struct function run() {
		var routeParser = new subsystems.openAPI.models.parsers.RouteParser(
			templates: this.getResourceRouteTemplates()
		);

		var routes = routeParser.parseRoutes(
			routes: this.getRoutes(),
			prefixes: this.getPrefixes()
		);

		var controllerParser = new subsystems.openAPI.models.parsers.ControllerParser();

		var openAPIDocument = new subsystems.openAPI.models.objects.Document();
		openAPIDocument.setInfo(variables.info);

		for (var route in routes) {
			var functions = controllerParser.parseFunctions(route.getSection());

			// If the item declared in the route isn't included in the controller's
			// items, skip it
			if (!structKeyExists(functions, route.getItem())) {
				continue;
			}

			var introspectedFunction = new subsystems.openAPI.models.IntrospectedFunction(functions[ route.getItem() ]);

			route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);
			route.parseUnconstrainedPathParameters(introspectedFunction: introspectedFunction);

			var parameters = introspectedFunction.getParameters();

			responses = introspectedFunction.getResponses();

			openAPIDocument.addPath(
				path: route.getDisplayPath(),
				method: route.getMethod(),
				summary: introspectedFunction.getHint(),
				parameters: parameters,
				responses: responses,
				requestBody: introspectedFunction.getRequestBody(),
				tags: introspectedFunction.getTags()
			);
		}

		var components = new subsystems.openAPI.models.objects.Components(variables.componentSchemaFolder).generate();
		openAPIDocument.setComponents(components);

		var spec = openAPIDocument.generate();

		// writeDump(spec);
		// abort;

		return spec;
	}
}
