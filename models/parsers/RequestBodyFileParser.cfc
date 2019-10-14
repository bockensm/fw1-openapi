component accessors="true" {
	public component function init() {
		return this;
	}


	public struct function parse(required string schemaFile) {
		var schemaFilePath = expandPath(arguments.schemaFile);
		var fileExists = fileExists(schemaFilePath);

		if (!fileExists) {
			// TODO: Log warning
			return {};
		}

		var fileData = fileRead(schemaFilePath, "utf-8");
		if (!isJSON(fileData)) {
			// TODO: Log warning
			return {};
		}

		var requestBody = deserializeJSON(fileData);

		if (structKeyExists(requestBody, "content")) {
			return this.parseFull(requestBody: requestBody);
		}

		writeOutput("parse incomplete file");
		writeDump(requestBody);
		abort;

		for (var parameterName in parameters) {
			var rawParameter = parameters[parameterName];
			var normalizedParameter = this.normalizeParameter(parameter: rawParameter);
			parameters[parameterName] = normalizedParameter;

			if (normalizedParameter.required) {
				arrayAppend(requiredParameters, parameterName);
			}
		}

		return {
			"content": {
				"application/x-www-form-urlencoded": {
					"schema": {
						"type": "object",
						"properties": parameters,
						"required": requiredParameters
					}
				}
			}
		};
	}


	package struct function normalizeParameter(required struct parameter) {
		var normalizedData = {
			"description": "",
			"type": "",
			"required": false
		};

		if (structKeyExists(arguments.parameter, "description") && isSimpleValue(arguments.parameter.description)) {
			normalizedData.description = arguments.parameter.description;
		}

		if (structKeyExists(arguments.parameter, "type") && isSimpleValue(arguments.parameter.type)) {
			normalizedData.type = arguments.parameter.type;
		}

		if (structKeyExists(arguments.parameter, "required") && isBoolean(arguments.parameter.required)) {
			normalizedData.required = arguments.parameter.required ? true : false;
		}

		return normalizedData;
	}


	package struct function parseFull(required struct requestBody) {
		// TODO: Normalize
		return arguments.requestBody;
	}
}
