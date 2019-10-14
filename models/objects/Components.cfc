component accessors="true" {
	public component function init(required string schemaFolder) {
		variables.schemaFolder = arguments.schemaFolder;
		return this;
	}


	public struct function generate() {
		if (!directoryExists(variables.schemaFolder)) {
			if (!directoryExists( expandPath(variables.schemaFolder) )) {
				// TODO: Log warning
				return {};
			}

			variables.schemaFolder = expandPath(variables.schemaFolder);
		}

		var components = {
			"schemas": {}
		};

		var schemas = directoryList(variables.schemaFolder);
		for (var schemaFilePath in schemas) {
			var schemaFileContents = fileRead(schemaFilePath, "utf-8");
			if (!isJSON(schemaFileContents)) {
				// TODO: Log warning
				continue;
			}

			var schemaFileName = getFileFromPath(schemaFilePath);
			var schemaName = listFirst(schemaFileName, ".");
			var schema = deserializeJSON(schemaFileContents);

			components.schemas[schemaName] = schema;
		}

		return components;
	}
}
