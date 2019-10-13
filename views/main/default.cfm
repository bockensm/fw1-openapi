<div id="swagger-ui"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/3.23.11/swagger-ui-bundle.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/3.23.11/swagger-ui-standalone-preset.js"></script>
<link href="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/3.23.11/swagger-ui.css" rel="stylesheet" />


<script>
	let spec = <cfoutput>#serializeJSON( rc.spec )#</cfoutput>;

	const ui = SwaggerUIBundle({
		spec: spec,
		dom_id: "#swagger-ui"
	})
</script>
