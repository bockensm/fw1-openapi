component accessors="true" {
	property section;
	property item;
	property method;
	property path;
	property displayPath;

	public component function init(required struct route) {
		this.parseRoute(arguments.route);

		return this;
	}


	/**
	 * Takes a key-value pair that's defined in the "routes" member
	 * of the framework settings and extracts all the required information
	 * about that route
	 *
	 * @route Key-value pair from the framework's routes
	 */
	public void function parseRoute(required struct route) {
		var path = structKeyList(arguments.route);
		var action = arguments.route[path];
		var section = listFirst(action, "/");
		var item = listGetAt(action, 2, "/");

		// GET until proven otherwise
		var method = "get";
		if (reFind("^\$", path)) {
			method = replace(listFirst(path, "/"), "$", "");
			method = lCase(method);

			path = "/" & listRest(path, "/");
		}

		this.setSection(section);
		this.setItem(item);
		this.setMethod(method);
		this.setPath(path);
		this.setDisplayPath(path);
	}


	/**
	 * Parses parameters that are constrained by a regex in the route declaration
	 *
	 * @introspectedFunction IntrospectedFunction object that may contain the hint for each path parameter
	 */
	public array function parseConstrainedPathParameters(required component introspectedFunction) {
		var parsedParameters = [];

		var regex = "\{([^:]+).*}";
		var parameters = reMatchNoCase(regex, this.getPath());

		for (var parameter in parameters) {
			var actualParameter = reReplaceNoCase(parameter, regex, "\1");
			var formattedParameter = "{" & actualParameter & "}";

			this.setDisplayPath( replace(this.getDisplayPath(), parameter, formattedParameter) );

			var description = arguments.introspectedFunction.getParameterDescription(
				parameter: actualParameter
			);

			arrayAppend(parsedParameters, {
				"name": actualParameter,
				"in": "path",
				"required": true,
				"description": description
			});
		}

		return parsedParameters;
	}


	/**
	 * Parses parameters that are not constrained by a regex in the route declaration
	 */
	public array function parseUnconstrainedPathParameters(required component introspectedFunction) {
		var parsedParameters = [];

		var regex = "\/:([^\/]+)";
		var parameters = reMatchNoCase(regex, this.getPath());

		for (var parameter in parameters) {
			var actualParameter = reReplaceNoCase(parameter, regex, "\1");
			var formattedParameter = "/{" & actualParameter & "}";

			this.setDisplayPath( replace(this.getDisplayPath(), parameter, formattedParameter) );

			var description = arguments.introspectedFunction.getParameterDescription(
				parameter: actualParameter
			);

			arrayAppend(parsedParameters, {
				"name": actualParameter,
				"in": "path",
				"required": true,
				"description": description
			});
		}

		return parsedParameters;
	}


	/**
	 * Sets the "section" variable for the object.
	 * Overrides the default setter for enhanced privacy.
	 */
	package void function setSection(required string section) {
		variables.section = arguments.section;
	}


	/**
	 * Sets the "item" variable for the object.
	 * Overrides the default setter for enhanced privacy.
	 */
	package void function setItem(required string item) {
		variables.item = arguments.item;
	}


	/**
	 * Sets the "method" variable for the object.
	 * Overrides the default setter for enhanced privacy.
	 */
	package void function setMethod(required string method) {
		variables.method = arguments.method;
	}


	/**
	 * Sets the "path" variable for the object.
	 * Overrides the default setter for enhanced privacy.
	 */
	package void function setPath(required string path) {
		variables.path = arguments.path;
	}


	/**
	 * Sets the "displayPath" variable for the object.
	 * Overrides the default setter for enhanced privacy.
	 */
	package void function setDisplayPath(required string displayPath) {
		variables.displayPath = arguments.displayPath;
	}
}
