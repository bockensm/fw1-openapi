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
	 * @subsystem The name of the FW/1 subsystem the controller is in
	 */
	public function parseFunctions(required string controller, string subsystem="") {
		try {
			var metadata = this.getMetadata(
				controller: arguments.controller,
				subsystem: arguments.subsystem
			);
		}
		catch (any exception) {
			if (structKeyExists(exception, "missingFileName")) {
				return {};
			}
			else {
				rethrow;
			}
		}

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
	 * @subsystem The name of the FW/1 subsystem the controller is in
	 */
	package struct function getMetadata(required string controller, string subsystem="") {
		var controllerDotPath = "controllers.#arguments.controller#";
		if (len(arguments.subsystem)) {
			controllerDotPath = "subsystems.#arguments.subsystem#.#controllerDotPath#";
		}

		if (!structKeyExists(variables.metadataCache, arguments.controller)) {
			variables.metadataCache[ arguments.controller ] = getComponentMetadata(controllerDotPath);
		}

		return variables.metadataCache[ arguments.controller ];
	}
}
