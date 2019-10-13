component accessors="true" {
	property prefixes;
	property routes;

	public component function init() {
		this.setPrefixes([ "/api" ]);

		variables.info = {
			"title": "",
			"description": "",
			"termsOfService": "",
			"contact": {
				"name": "",
				"url": "",
				"email": ""
			},
			"version": ""
		};

		return this;
	}


	/**
	 * Takes a configuration struct and overlays it atop the default config
	 *
	 * @config Structure containing configuration data
	 */
	public void function configure(required struct config) {
		if (structKeyExists(config, "info")) {
			structAppend(variables.info, config.info);
		}
	}


	/**
	 * Takes all provided input and returns a structure that
	 * represents an OpenAPI-compatible respresentation of
	 * the declared routes
	 */
	public struct function run() {
		var routeParser = new subsystems.openAPI.models.parsers.RouteParser();
		var routes = routeParser.parseRoutes(
			routes: this.getRoutes(),
			prefixes: this.getPrefixes()
		);

		var controllerParser = new subsystems.openAPI.models.parsers.ControllerParser();

		var openAPIDocument = new subsystems.openAPI.models.objects.Document();
		openAPIDocument.setInfo(variables.info);

		for (var route in routes) {
			var functions = controllerParser.parseFunctions(route.getSection())

			// If the item declared in the route isn't included in the controller's
			// items, skip it
			if (!structKeyExists(functions, route.getItem())) {
				continue;
			}

			var introspectedFunction = new subsystems.openAPI.models.IntrospectedFunction(functions[ route.getItem() ]);

			var constrainedPathParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);
			var unconstrainedPathParameters = route.parseUnconstrainedPathParameters(introspectedFunction: introspectedFunction);
			var queryParameters = introspectedFunction.getQueryParameters();

			var parameters = [];
			arrayAppend(parameters, constrainedPathParameters, true);
			arrayAppend(parameters, unconstrainedPathParameters, true);
			arrayAppend(parameters, queryParameters, true);

			openAPIDocument.addPath(
				path: route.getDisplayPath(),
				method: route.getMethod(),
				summary: introspectedFunction.getHint(),
				parameters: parameters,
				tags: introspectedFunction.getTags()
			);
		}

		var spec = openAPIDocument.generate();

		return spec;
	}
}
