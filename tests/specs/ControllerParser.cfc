component extends="testbox.system.BaseSpec" {

/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll() {
		application.controllerParser = new subsystems.openapi.models.parsers.ControllerParser();
	}

	function afterAll() {
		structClear( application );
	}

/*********************************** BDD SUITES ***********************************/

	function run() {
		describe("Valid Controller Tests", function() {
			it("should support introspection on a valid controller", function() {
				var functions = application.controllerParser.parseFunctions(
					controller: "main",
					subsystem: "openAPI"
				);

				expect(functions).toBeStruct();
				expect(functions).notToBeEmpty();
			});
		});

		describe("Invalid Controller Tests", function() {
			it("should support introspection on a valid controller", function() {
				var functions = application.controllerParser.parseFunctions(
					controller: "invalid",
					subsystem: "openAPI"
				);

				expect(functions).toBeStruct();
				expect(functions).toBeEmpty();
			});
		});
	}
}
