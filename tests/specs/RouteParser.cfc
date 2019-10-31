component extends="testbox.system.BaseSpec" {

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll() {
		application.routeParser = new subsystems.openapi.models.parsers.RouteParser();
	}

	function afterAll() {
		structClear( application );
	}

/*********************************** BDD SUITES ***********************************/

	function run() {
		describe("Valid Route Tests", function() {
			it("supports the simplest route declaration", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports $GET routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports $POST routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$POST/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports $PUT routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PUT/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports $PATCH routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports $DELETE routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$DELETE/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
			});

			it("supports multiple routes in one struct", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/cats/index", "$POST/api/cats": "/cats/create" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(2);
			});

			it("supports a subsystem route", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/api:cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).notToBeEmpty();
				expect(parsedRoutes[1].getSection()).toBe("cats");
				expect(parsedRoutes[1].getSubsystem()).toBe("api");
			});
		});

		describe("Invalid Route Tests", function() {
			it("ignores routes with an invalid method", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$INVALID/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toBeEmpty();
			});

			it("ignores $* routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$*/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toBeEmpty();
			});

			it("ignores * routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "*": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toBeEmpty();
			});

			it("ignores routes that don't match a prefix", function() {
				var parsedRoutes = application.routeParser.parseRoutes(
					routes: [
						{ "/api/cats": "/cats/index" },
						{ "/dogs": "/dogs/index" }
					],
					prefixes: [ "/api" ]
				);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);
			});

			it("ignores routes that try to invoke the module's subsystem", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "/api/cats": "/openAPI:cats/index" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toBeEmpty();
			});
		});

		describe("Resources Tests", function() {
			it("supports $RESOURCES routes with a string", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$RESOURCES": "cats,mice" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(14);
			});

			it("supports $RESOURCES routes with an array", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$RESOURCES": [ "cats", "mice" ] }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(14);
			});

			it("supports $RESOURCES routes with an object", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{
						"$RESOURCES": {
							resources: "cats,mice"
						}
					}
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(14);
			});

			it("supports $RESOURCES for a subsystem", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{
						"$RESOURCES": {
							resources: "cats,mice",
							subsystem: "api"
						}
					}
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(14);
				expect(parsedRoutes[1].getSubsystem()).toBe("api");
			});
		});
	}
}
