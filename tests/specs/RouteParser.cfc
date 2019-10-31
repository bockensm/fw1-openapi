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

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports $GET routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports $POST routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$POST/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports $PUT routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PUT/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports $PATCH routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports $DELETE routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$DELETE/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
			});

			it("supports multiple routes in one struct", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/cats/index", "$POST/api/cats": "/cats/create" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(2);
			});

			it("supports a subsystem route", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats": "/api:cats/index" }
				]);

				expect(parsedRoutes).toBeArray().notToBeEmpty();
				expect(parsedRoutes[1].getSection()).toBe("cats");
				expect(parsedRoutes[1].getSubsystem()).toBe("api");
			});
		});

		describe("Invalid Route Tests", function() {
			it("ignores routes with an invalid method", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$INVALID/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().toBeEmpty();
			});

			it("ignores $* routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$*/api/cats": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().toBeEmpty();
			});

			it("ignores * routes", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "*": "/cats/index" }
				]);

				expect(parsedRoutes).toBeArray().toBeEmpty();
			});

			it("ignores routes that don't match a prefix", function() {
				var parsedRoutes = application.routeParser.parseRoutes(
					routes: [
						{ "/api/cats": "/cats/index" },
						{ "/dogs": "/dogs/index" }
					],
					prefixes: [ "/api" ]
				);

				expect(parsedRoutes).toBeArray().toHaveLength(1);
			});

			it("ignores routes that try to invoke the module's subsystem", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "/api/cats": "/openAPI:cats/index" }
				]);

				expect(parsedRoutes).toBeArray().toBeEmpty();
			});
		});

		describe("Resources Tests", function() {
			it("supports $RESOURCES routes with a string", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$RESOURCES": "cats,mice" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(14);
			});

			it("supports $RESOURCES routes with an array", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$RESOURCES": [ "cats", "mice" ] }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(14);
			});

			it("supports $RESOURCES routes with an object", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{
						"$RESOURCES": {
							resources: "cats,mice"
						}
					}
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(14);
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

				expect(parsedRoutes).toBeArray().toHaveLength(14);
				expect(parsedRoutes[1].getSubsystem()).toBe("api");
			});
		});

		describe("Parameter Parsing Tests", function() {
			it("supports routes with multiple constrained parameters", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/{id:[0-9]+}/toys/{toyID:[0-9]+}": "/cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(1);

				var route = parsedRoutes[1];

				var constrainedParameters = this.getConstrainedParameters(route: route);
				expect(constrainedParameters).toBeArray().toHaveLength(2);
			});

			it("supports routes with multiple unconstrained parameters", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/:id/toys/:toyID": "/cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(1);

				var route = parsedRoutes[1];

				var unconstrainedParameters = this.getUnconstrainedParameters(route: route);
				expect(unconstrainedParameters).toBeArray().toHaveLength(2);
			});

			it("supports routes with a mix of constrained and unconstrained parameters (first one is constrained)", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/{id:[0-9]+}/toys/:toyID": "/cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var route = parsedRoutes[1];

				var constrainedParameters = this.getConstrainedParameters(route: route);
				expect(constrainedParameters).toBeArray().toHaveLength(1);
				expect(constrainedParameters[1].name).toBe("id");

				var unconstrainedParameters = this.getUnconstrainedParameters(route: route);
				expect(unconstrainedParameters).toBeArray().toHaveLength(1);
				expect(unconstrainedParameters[1].name).toBe("toyID");
			});

			it("supports routes with a mix of constrained and unconstrained parameters (first one is unconstrained)", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$PATCH/api/cats/:id/toys/{toyID:[0-9]+}": "/cats/update/id/:id/toy/:id" }
				]);

				expect(parsedRoutes).toBeArray();
				expect(parsedRoutes).toHaveLength(1);

				var route = parsedRoutes[1];

				var constrainedParameters = this.getConstrainedParameters(route: route);
				expect(constrainedParameters).toBeArray().toHaveLength(1);
				expect(constrainedParameters[1].name).toBe("toyID");

				var unconstrainedParameters = this.getUnconstrainedParameters(route: route);
				expect(unconstrainedParameters).toBeArray().toHaveLength(1);
				expect(unconstrainedParameters[1].name).toBe("id");
			});

			it("correctly parses a numeric parameter constraint with an upper limit (i.e. [0-9])", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats/{id:[0-9]}": "/cats/index/id/:id" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(1);

				var route = parsedRoutes[1];

				var constrainedParameters = this.getConstrainedParameters(route: route);

				expect(constrainedParameters).toBeArray().toHaveLength(1);
				expect(constrainedParameters[1].schema.type).toBe("integer");
				expect(constrainedParameters[1].schema).toHaveKey("maximum");
			});

			it("correctly parses a numeric parameter constraint with no upper limit (i.e. [0-9]+)", function() {
				var parsedRoutes = application.routeParser.parseRoutes([
					{ "$GET/api/cats/{id:[0-9]+}": "/cats/index/id/:id" }
				]);

				expect(parsedRoutes).toBeArray().toHaveLength(1);

				var route = parsedRoutes[1];
				var constrainedParameters = this.getConstrainedParameters(route: route);

				expect(constrainedParameters).toBeArray().toHaveLength(1);
				expect(constrainedParameters[1].schema.type).toBe("integer");
				expect(constrainedParameters[1].schema).notToHaveKey("maximum");
			});
		});
	}


	package function getConstrainedParameters(required component route) {
		return arguments.route.parseConstrainedPathParameters(
			introspectedFunction: new subsystems.openapi.models.IntrospectedFunction(
				this.mockFunction(name: arguments.route.getItem())
			)
		);
	}


	package function getUnconstrainedParameters(required component route) {
		return arguments.route.parseUnconstrainedPathParameters(
			introspectedFunction: new subsystems.openapi.models.IntrospectedFunction(
				this.mockFunction(name: arguments.route.getItem())
			)
		);
	}


	package struct function mockFunction(required string name) {
		return {
			"name": arguments.name,
			"access": "public",
			"parameters": [],
			"returntype": "void",
			"tags": "[]"
		};
	}
}
