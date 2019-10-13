component accessors="true" {
	public component function init(required struct paths) {
		variables.paths = arguments.paths;

		return this;
	}


	public struct function generate() {
		return variables.paths;
	}
}
