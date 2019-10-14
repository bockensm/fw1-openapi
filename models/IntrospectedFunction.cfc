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
	public array function getParameters() {
		return variables.data.parameters;
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
	 * Returns any responses that are described in the function's JavaDoc
	 *
	 * @data Defined responses
	 */
	public struct function getResponses() {
		return variables.data.responses;
	}


	public struct function getRequestBody() {
		return variables.data.requestBody;
	}


	/**
	 * Takes provided input that comes from the "functions" member of
	 * `getControllerMetadata` and normalizes it to ensure all data that
	 * may be needed is present and in a satisfactory state.
	 *
	 * @data Function information from introspection
	 */
	package struct function normalize(required struct data) {
		var normalizedData = duplicate(arguments.data);
		param normalizedData.hint = "";
		param normalizedData.tags = "[]";
		param normalizedData.responses = "";
		param name="normalizedData['x-parameters']" default="";

		var returnData = {
			"hint": normalizedData.hint,
			"parameters": [],
			"responses": this.parseResponses(data: normalizedData),
			"requestBody": {},
			"tags": []
		};

		if (isSimpleValue(normalizedData.tags) && isJSON(normalizedData.tags)) {
			returnData.tags = deserializeJSON(normalizedData.tags);
		}

		var queryParameters = this.parseParamsByType(
			data: normalizedData,
			type: "query"
		);
		arrayAppend(returnData.parameters, queryParameters, true);

		var pathParameters = this.parseParamsByType(
			data: normalizedData,
			type: "path"
		);
		arrayAppend(returnData.parameters, pathParameters, true);

		if (len(normalizedData["x-parameters"])) {
			var requestBodyFileParser = new subsystems.openAPI.models.parsers.RequestBodyFileParser();
			returnData.requestBody = requestBodyFileParser.parse(
				schemaFile: normalizedData["x-parameters"]
			);
		}

		return returnData;
	}


	/**
	 * Finds declared parameters by a specified type. If the parameter is declared
	 * in both x-parameters and also in the JavaDoc directly, what's in the JavaDoc
	 * will override the schema file declaration if the types are the same.
	 *
	 * @data Introspected function data
	 * @type Which type of parameter to parse
	 */
	package array function parseParamsByType(required struct data, required string type) {
		var parameters = [];

		for (var key in arguments.data) {
			if (!reFindNoCase("^param-", key)) {
				continue;
			}

			var parameter = this.parseParam(parameter: key, data: arguments.data[key]);
			if (parameter.in == arguments.type) {
				arrayAppend(parameters, parameter);
			}
		}

		return parameters;
	}


	/**
	 * Parses and normalizes a @param- line from the JavaDoc block
	 *
	 * @parameter Raw string declared as a parameter
	 * @data Corresponding parameter data from the JavaDoc
	 */
	package struct function parseParam(required string parameter, required string data) {
		var paramName = lCase(listRest(parameter, "-"));

		if (!isJSON(arguments.data)) {
			var normalizedParam = this.normalizeParam(name: paramName);
		}
		else {
			var params = deserializeJSON(arguments.data);

			var normalizedParam = this.normalizeParam(name: paramName, argumentCollection: params);
			normalizedParam["description"] = normalizedParam.hint;
			structDelete(normalizedParam, "hint");
		}

		return normalizedParam;
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


	package struct function parseResponses(required struct data) {
		if (structKeyExists(arguments.data, "responses")) {
			if (!isSimpleValue(arguments.data.responses)) {
				// TODO: Log warning
				return {};
			}

			if (len(arguments.data.responses)) {
				var responseFileParser = new subsystems.openAPI.models.parsers.ResponseFileParser();
				return responseFileParser.parse(arguments.data.responses);
			}
		}

		var responses = createObject("java", "java.util.LinkedHashMap").init();

		// Normalize data for @param- entries
		for (var key in arguments.data) {
			if (!reFindNoCase("^response-", key)) {
				continue;
			}

			var response = this.parseResponse(parameter: key, data: arguments.data[key]);
			if (!structIsEmpty(response)) {
				var statusCode = response.statusCode;
				structDelete(response, "statusCode");
				responses[statusCode] = response;
			}
		}

		return responses;
	}


	package struct function parseResponse(required string parameter, required string data) {
		if (!isJSON(arguments.data)) {
			return {};
		}

		var statusCode = lCase(listRest(parameter, "-"));
		var params = deserializeJSON(arguments.data);

		return this.normalizeResponse(statusCode: statusCode, argumentCollection: params);
	}


	package struct function normalizeResponse() {
		var data = duplicate(arguments);

		param data.description = "";
		param data.content = "";

		return data;
	}
}
