# OpenAPI generator for FW/1 Applications
This subsystem is intended to generate OpenAPI 3-compatible JSON that is
fed in to [Swagger UI](https://swagger.io/tools/swagger-ui/) to create a
browser-based documentation portal/playground for your FW/1 API.

## Usage
* Clone this repository inside the `subsystems` folder of your FW/1 application
* Declare a route in `variables.framework.routes`, e.g. `{ "$GET/api": "/openapi:main/default" }`
* Configure SwaggerUI (more information to come later)
* Hit the declared route in the browser and watch the magic happen

## Disclaimers
This has only been tested with the exact scenario outlined in
[fw1-openapi-example](https://github.com/bockensm/fw1-openapi-example). Any usage
outside of that specific scenario has not been tested, but that doesn't mean it
can't work.

Authenticated APIs have not been tested. This only works with really basic setups
at this moment.
