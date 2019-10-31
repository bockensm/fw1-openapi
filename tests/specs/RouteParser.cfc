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

			it("supports routes with multiple constrained parameters", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/{id:[0-9]+}/toys/{toyID:[0-9]+}": "/api:cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var constrainedParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);

				expect(constrainedParameters).toBeArray();
				expect(constrainedParameters).toHaveLength(2);
			});

			it("supports routes with multiple unconstrained parameters", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/:id/toys/:toyID": "/api:cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var unconstrainedParameters = route.parseUnconstrainedPathParameters(introspectedFunction: introspectedFunction);

				expect(unconstrainedParameters).toBeArray();
				expect(unconstrainedParameters).toHaveLength(2);
			});

			it("supports routes with a mix of constrained and unconstrained parameters (first one is constrained)", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/{id:[0-9]+}/toys/:toyID": "/api:cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var constrainedParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);
				expect(constrainedParameters).toBeArray();
				expect(constrainedParameters).toHaveLength(1);
				expect(constrainedParameters[1].name).toBe("id");

				var unconstrainedParameters = route.parseUnconstrainedPathParameters(introspectedFunction: introspectedFunction);
				expect(unconstrainedParameters).toBeArray();
				expect(unconstrainedParameters).toHaveLength(1);
				expect(unconstrainedParameters[1].name).toBe("toyID");
			});

			it("supports routes with a mix of constrained and unconstrained parameters (first one is unonstrained)", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/:id/toys/{toyID:[0-9]+}": "/api:cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var constrainedParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);
				expect(constrainedParameters).toBeArray();
				expect(constrainedParameters).toHaveLength(1);
				expect(constrainedParameters[1].name).toBe("toyID");

				var unconstrainedParameters = route.parseUnconstrainedPathParameters(introspectedFunction: introspectedFunction);
				expect(unconstrainedParameters).toBeArray();
				expect(unconstrainedParameters).toHaveLength(1);
				expect(unconstrainedParameters[1].name).toBe("id");
			});

			it("correctly parses a numeric parameter constraint with an upper limit", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats/{id:[0-9]}": "/api:cats/index/id/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var constrainedParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);

				expect(constrainedParameters).toBeArray();
				expect(constrainedParameters).toHaveLength(1);
				expect(constrainedParameters[1].schema.type).toBe("integer");
				expect(constrainedParameters[1].schema).toHaveKey("maximum");
			});

			it("correctly parses a numeric parameter constraint with no upper limit", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats/{id:[0-9]+}": "/api:cats/index/id/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var controllerParser = new subsystems.openapi.models.parsers.ControllerParser();

				var route = parsedRoutes[1];
				var functions = controllerParser.parseFunctions(
					controller: route.getSection(),
					subsystem: route.getSubsystem()
				);

				var introspectedFunction = new subsystems.openapi.models.IntrospectedFunction(functions[ route.getItem() ]);
				var constrainedParameters = route.parseConstrainedPathParameters(introspectedFunction: introspectedFunction);

				expect(constrainedParameters).toBeArray();
				expect(constrainedParameters).toHaveLength(1);
				expect(constrainedParameters[1].schema.type).toBe("integer");
				expect(constrainedParameters[1].schema).notToHaveKey("maximum");
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
