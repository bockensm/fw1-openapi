component accessors="true" {
	public component function init() {
		variables.metadataCache = {};

		return this;
	}


	/**
	 * Returns information about the functions that are declared
	 * in a provided controller.
	 *
	 * @controller The name of the FW/1 controller
	 */
	public function parseFunctions(required string controller) {
		var metadata = this.getMetadata(controller: controller);
		var functions = metadata.functions;

		var map = {};
		for (var fn in functions) {
			map[ fn.name ] = fn;
		}

		return map;
	}


	/**
	 * Gets metadata about a controller. Looks it up in the internal cache
	 * first, and gets the metadata if it's not there.
	 *
	 * @controller The name of the FW/1 controller
	 */
	package struct function getMetadata(required string controller) {
		if (!structKeyExists(variables.metadataCache, arguments.controller)) {
			variables.metadataCache[ arguments.controller ] = getComponentMetadata("controllers.#arguments.controller#");
		}

		return variables.metadataCache[ arguments.controller ];
	}
}
