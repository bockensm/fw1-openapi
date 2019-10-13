component accessors="true" {
	public component function init(required struct info) {
		variables.info = arguments.info;

		return this;
	}


	public struct function generate() {
		return variables.info;
	}
}
