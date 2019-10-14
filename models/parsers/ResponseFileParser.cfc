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

		var responses = deserializeJSON(fileData);

		for (var statusCode in responses) {
			var rawResponse = responses[statusCode];
			var normalizedResponse = this.normalizeResponse(response: rawResponse);
			responses[statusCode] = normalizedResponse;
		}

		return responses;
	}


	package struct function normalizeResponse(required struct response) {
		var normalizedData = {
			"description": "",
			"content": ""
		};

		if (structKeyExists(arguments.response, "description") && isSimpleValue(arguments.response.description)) {
			normalizedData.description = arguments.response.description;
		}

		if (
			structKeyExists(arguments.response, "type")
			&& isSimpleValue(arguments.response.type)
			&& structKeyExists(arguments.response, "item")
			&& isSimpleValue(arguments.response.item)
		) {
			var schema = {};
			if (arguments.response.type == "object") {
				schema = {
					"$ref": arguments.response.item
				};
			}
			else {
				schema = {
					"type": arguments.response.type,
					"items": {
						"$ref": arguments.response.item
					}
				};
			}

			normalizedData.content = {
				"application/json": {
					"schema": schema
				}
			};
		}

		return normalizedData;
	}
}
