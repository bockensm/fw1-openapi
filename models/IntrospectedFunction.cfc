component accessors="true" {
	public component function init(required struct data) {
		variables.data = this.normalize(data);

		return this;
	}


	/**
	 * Returns a normalized set of query parameters that have been documented
	 * in the JavaDoc information for a given function. These are all
	 * preceded by @param- in the JavaDoc.
	 */
	public array function getQueryParameters() {
		return variables.data.queryParams;
	}


	/**
	 * Returns a normalized set of query parameters that have been documented
	 * in the JavaDoc information for a given function. These are all
	 * preceded by @param- in the JavaDoc.
	 */
	public array function getPathParameters() {
		return variables.data.pathParams;
	}


	/**
	 * Gets the function hint that is determined by introspecting the
	 * controller's metadata.
	 */
	public string function getHint() {
		return variables.data.hint;
	}


	/**
	 * Gets the list of tags attached to a function. These are determined
	 * by introspecting the controller's metadata.
	 */
	public array function getTags() {
		return variables.data.tags;
	}


	/**
	 * Returns the documented description of a defined parameter
	 *
	 * @parameter Parameter documented in the JavaDoc
	 */
	public string function getParameterDescription(required string parameter) {
		for (var key in variables.data) {
			if (key != "param-" & arguments.parameter) {
				continue;
			}

			var data = variables.data[ key ];

			// If it looks like JSON, serialize it and look for the "hint"
			if (isJSON(data)) {
				data = deserializeJSON(data);
				if (structKeyExists(data, "hint")) {
					data = data.hint;
				}
			}

			// Safeguard in case something unexpected is provided
			if (!isSimpleValue(data)) {
				return "";
			}

			return data;
		}

		return "";
	}


	/**
	 * Takes provided input that comes from the "functions" member of
	 * `getControllerMetadata` and normalizes it to ensure all data that
	 * may be needed is present and in a satisfactory state.
	 *
	 * @data Function information from introspection
	 */
	package struct function normalize(required struct data) {
		param arguments.data.hint = "";
		param arguments.data.tags = "[]";

		if (isSimpleValue(arguments.data.tags) && isJSON(arguments.data.tags)) {
			arguments.data.tags = deserializeJSON(arguments.data.tags);
		}

		arguments.data.queryParams = [];
		arguments.data.pathParams = [];

		// Normalize data for @param- entries
		for (var key in arguments.data) {
			if (!reFindNoCase("^param-", key)) {
				continue;
			}

			var paramName = lCase(listRest(key, "-"));

			if (!isJSON(arguments.data[key])) {
				var normalizedParam = this.normalizeParam(name: paramName);
			}
			else {
				var params = deserializeJSON( arguments.data[key] );

				var normalizedParam = this.normalizeParam(name: paramName, argumentCollection: params);
				normalizedParam["description"] = normalizedParam.hint;
				structDelete(normalizedParam, "hint");
			}

			if (normalizedParam.in == "query") {
				arrayAppend(arguments.data.queryParams, normalizedParam);
			}
			else if (normalizedParam.in == "path") {
				arrayAppend(arguments.data.pathParams, normalizedParam);
			}
		}

		return arguments.data;
	}


	/**
	 * Takes provided input for one of the params documented in the function's
	 * JavaDoc block and ensures that all necessary data is present and in
	 * a satisfactory state.
	 */
	package struct function normalizeParam() {
		var data = duplicate(arguments);

		param data.name = "";
		param data.in = "";
		param data.hint = "";
		param data.required = false;

		// This looks stupid, but it coerces the variable from a string to
		// a boolean, so it's actually quite important.
		data.required = data.required ? true : false;

		if (structKeyExists(data, "type") && len(data.type)) {
			data["schema"] = {
				"type": data.type
			};
		}

		return data;
	}
}
