component accessors="true" {
	public component function init() {
		variables.tags = [];

		return this;
	}


	public array function extractFromPaths(required struct paths) {
		var tags = [];

		for (var path in paths) {
			var methods = paths[path];

			for (var method in methods) {
				var route = methods[method];
				if (!structKeyExists(route, "tags")) {
					continue;
				}

				for (var tag in route.tags) {
					if (!arrayFindNoCase(tags, tag)) {
						tags.add(tag);
					}
				}
			}
		}

		return tags.sort("textnocase", "asc").map(function(tag, index) {
			return { "name": tag };
		});
	}
}
