component accessors="true" {
	property Info;
	property name="ComponentSchemaFolder" default="/components/schemas/";
	property Prefixes;

	public component function init(string customConfigPath="") {
		var config = {};
		if (len(arguments.customConfigPath)) {
			var configurator = createObject("component", arguments.customConfigPath);
			config = configurator.configure();
		}

		var mergedInfo = this.mergeCustomConfigWithDefault(
			customConfig: config,
			key: "info"
		);

		this.setInfo(mergedInfo);

		if (structKeyExists(config, "componentSchemaFolder")) {
			this.setComponentSchemaFolder(config.componentSchemaFolder);
		}

		if (structKeyExists(config, "prefixes")) {
			this.setPrefixes(config.prefixes);
		}
		else {
			this.setPrefixes([ "/api" ]);
		}

		return this;
	}


	/**
	 * Merges any custom configuration data with a default
	 *
	 * @customConfig Structure of custom config data that gets set atop the default
	 * @key Key used in the JSON data
	 */
	package struct function mergeCustomConfigWithDefault(required struct customConfig, required string key) {
		var defaultData = this.getDefaultConfig(key: arguments.key);
		// If the custom config doesn't contain the desired data, return the default data
		if (!structKeyExists(customConfig, arguments.key)) {
			return defaultData;
		}

		structAppend(defaultData, customConfig[arguments.key]);

		return defaultData;
	}


	/**
	 * Gets some default data
	 *
	 * @key Which data to get
	 */
	package struct function getDefaultConfig(required string key) {
		var defaults = {
			"info": {
				"title": "",
				"description": "",
				"termsOfService": "",
				"contact": {
					"name": "",
					"url": "",
					"email": ""
				},
				"version": ""
			}
		};

		if (structKeyExists(defaults, arguments.key)) {
			return defaults[key];
		}

		return {};
	}
}
