component accessors="true" {
	public component function init() {
		return this;
	}


	/**
	 * Parses a array of routes that are declared by the framework and
	 * removes any routes that don't match one of the declared prefixes
	 *
	 * @routes The routes that have been declared in the "routes" key of the framework settings
	 * @prefixes Array of prefixes for routes that we want to document in SwaggerUI
	 */
	public array function parseRoutes(required array routes, array prefixes=[]) {
		var allowedRoutes = [];

		for (var item in arguments.routes) {
			// Exclude routes that start with $* because it can't be documented
			if (reFindNoCase("^\$\*", structKeyList(item))) {
				continue;
			}

			var route = new subsystems.openAPI.models.Route(item);

			// Exclude any routes declared as part of this subsystem
			if (reFindNoCase("^openAPI:", route.getSection())) {
				continue;
			}



			// Ensure that the route matches at least one of the configured prefixes
			if (!this.isRouteIncluded(path: route.getPath(), prefixes: arguments.prefixes)) {
				continue;
			}

			arrayAppend(allowedRoutes, route);
		}

		return allowedRoutes;
	}


	/**
	 * Does the comparison between a route URL and the prefix list to determine
	 * whether or not the route should be included
	 *
	 * @path A single route URL
	 * @prefixes Array of prefixes for routes that we want to document in SwaggerUI
	 */
	package boolean function isRouteIncluded(required string path, array prefixes=[]) {
		if (arrayLen(arguments.prefixes) == 0) {
			return true;
		}

		for (var prefix in prefixes) {
			if (reFindNoCase("^#prefix#", arguments.path)) {
				return true;
			}
		}

		return false;
	}
}
