component accessors="true" {
	property section;
	property item;
	property method;
	property path;
	property displayPath;
	property subsystem;

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
		var subsystem = "";

		if (listLen(section, ":") > 1) {
			subsystem = listFirst(section, ":");
			section = listRest(section, ":");
		}

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
		this.setSubsystem(subsystem);
	}


	/**
	 * Parses parameters that are constrained by a regex in the route declaration
	 *
	 * @introspectedFunction IntrospectedFunction object that may contain the hint for each path parameter
	 */
	public array function parseConstrainedPathParameters(required component introspectedFunction) {
		var parsedParameters = [];

		var regex = "\{([^:]+):([^\}]+)}";
		var parameters = reMatchNoCase(regex, this.getPath());

		for (var parameter in parameters) {
			var actualParameter = reReplaceNoCase(parameter, regex, "\1");
			var formattedParameter = "{" & actualParameter & "}";

			this.setDisplayPath( replace(this.getDisplayPath(), parameter, formattedParameter) );

			var description = arguments.introspectedFunction.getParameterDescription(
				parameter: actualParameter
			);

			var parameterData = {
				"name": actualParameter,
				"in": "path",
				"required": true,
				"description": description
			};

			// Look for a numeric constraint. Otherwise, assume string data is OK.
			var parameterConstraint = reReplaceNoCase(parameter, regex, "\2");
			if (find("[0-9]", parameterConstraint)) {
				parameterData["schema"] = {
					"type": "integer",
					"minimum": 0
				};

				if (!reFind("\+$", parameterConstraint)) {
					parameterData["schema"]["maximum"] = 9;
					parameterData["description"] &= " (Integer between 0 and 9, inclusive)";
				}
				else {
					parameterData["description"] &= "(Positive Integer)";
				}
			}
			else {
				parameterData["schema"] = {
					"type": "string"
				};
			}

			arrayAppend(parsedParameters, parameterData);
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
