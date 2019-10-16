component accessors="true" {
	property resourceRouteTemplates;

	public component function init(array templates=[]) {
		if (arrayLen(arguments.templates)) {
			this.setResourceRouteTemplates(arguments.templates);
		}
		else {
			this.setResourceRouteTemplates(this.getDefaultResourceRouteTemplates());
		}

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

		var routeProcessingQueue = this.expandResourceRoutes(routes: arguments.routes);

		for (var item in routeProcessingQueue) {
			for (var routePattern in structKeyList(item)) {
				// Exclude wildcard patterns because it can't be documented
				if (routePattern.startsWith("$*") || routePattern == "*") {
					continue;
				}

				// Since this supports multi-member structures, put a single struct
				// back together and feed it to Route
				var route = new subsystems.openAPI.models.Route({ "#routePattern#": item[routePattern] });

				// Exclude any routes declared as part of this subsystem
				if (route.getSubsystem() == "openAPI") {
					continue;
				}

				// Ensure that the route matches at least one of the configured prefixes
				if (!this.hasAllowedPrefix(path: route.getPath(), prefixes: arguments.prefixes)) {
					continue;
				}

				arrayAppend(allowedRoutes, route);
			}
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
	package boolean function hasAllowedPrefix(required string path, array prefixes=[]) {
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


	/**
	 * Ensures all the data in a $RESOURCES route is sane and accounted for
	 * @data The route data
	 */
	package struct function normalizeResourceRoute(required any data) {
		var normalizedData = {
			resources: "",
			methods: "",
			pathRoot: "",
			nested: "",
			subsystem: ""
		};

		if (isSimpleValue(data)) {
			normalizedData.resources = data;
		}
		else if (isArray(data)) {
			normalizedData.resources = arrayToList(data);
		}
		else if (isStruct(data)) {
			param data.resources = {};
			param data.methods = "";
			param data.pathRoot = "";
			param data.nested = "";
			param data.subsystem = "";

			if (isSimpleValue(data.resources)) {
				normalizedData.resources = data.resources;
			}

			if (isSimpleValue(data.methods)) {
				normalizedData.methods = data.methods;
			}

			if (isSimpleValue(data.pathRoot)) {
				normalizedData.pathRoot = data.pathRoot;
			}

			if (isSimpleValue(data.nested)) {
				normalizedData.nested = data.nested;
			}

			if (isSimpleValue(data.subsystem)) {
				normalizedData.subsystem = data.subsystem;
			}
		}

		if (!len(normalizedData.methods)) {
			var templates = this.getResourceRouteTemplates();
			for (var resource in templates) {
				normalizedData.methods = listAppend(normalizedData.methods, resource.method);
			}
		}

		return normalizedData;
	}


	/**
	 * Expands a $RESOURCES route declaration to its component routes.
	 * Appends any other declared route to the array for return.
	 * @routes Array of routes
	 */
	package array function expandResourceRoutes(required array routes) {
		var queue = [];
		var templates = this.getResourceRouteTemplates();

		for (var item in arguments.routes) {
			for (var routePattern in structKeyList(item)) {
				if (routePattern != "$RESOURCES") {
					arrayAppend(queue, { "#routePattern#": item[routePattern] });
					continue;
				}

				var resourceData = item[routePattern];
				var route = this.normalizeResourceRoute(data: resourceData);

				for (var resource in route.resources) {
					for (var method in route.methods) {
						for (var template in templates) {
							if (template.method != method) {
								continue;
							}

							for (var httpMethod in template.httpMethods) {
								var uri = httpMethod;
								uri &= route.pathRoot;
								uri &= "/" & resource;

								if (structKeyExists(template, "includeID") && template.includeID) {
									uri &= "/:id";
								}

								if (structKeyExists(template, "routeSuffix")) {
									uri &= template.routeSuffix;
								}

								arrayAppend(queue, { "#uri#": "/#resource#/#method#"});
							}
						}
					}
				}
			}
		}

		return queue;
	}


	// TODO: Get this directly from FW/1
	package array function getDefaultResourceRouteTemplates() {
		return [
			{ method = 'default', httpMethods = [ '$GET' ] },
			{ method = 'new', httpMethods = [ '$GET' ], routeSuffix = '/new' },
			{ method = 'create', httpMethods = [ '$POST' ] },
			{ method = 'show', httpMethods = [ '$GET' ], includeId = true },
			{ method = 'update', httpMethods = [ '$PUT','$PATCH' ], includeId = true },
			{ method = 'destroy', httpMethods = [ '$DELETE' ], includeId = true }
		];
	}
}
