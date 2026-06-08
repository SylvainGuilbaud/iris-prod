# iris-prod

This repository contains the production version and deployment-related setup for the IRIS project.

It creates a Docker Compose configuration to run both the IRIS database and the Web Gateway in a production-like environment. 

The IRIS instance is built from a custom Dockerfile that includes the necessary license key and application code to set up the REST API as defined in the `iris.script`. 
It creates a SC namespace using 2 databases (one for data and one for code) with interoperability enabled and configures a CSP application at `/csp/sc` with the appropriate dispatch class.
The application is enabled for DeepSee to allow for analytics capabilities.

It installs the ZPM package manager and uses it to enable the `isc-supply-chain` package.

The Web Gateway is set up to route requests to this application, allowing for secure access to the REST API.

## Docker Compose

The `docker-compose.yml` defines two services:

### `iris`
- Built from the `iris/` directory using `containers.intersystems.com/intersystems/iris:latest-em` as the base image.
- Exposes the IRIS SuperServer port 1972 on the host via `$IRIS_PORT`.
- Mounts `./iris-data` as the IRIS data directory and `iris/key/iris.key` (read-only) as the license key.
- Timezone is set to `Europe/Paris`.
- Restarts automatically unless manually stopped.

### `webgateway`
- Uses `containers.intersystems.com/intersystems/webgateway:latest-em` directly (no custom build).
- Depends on the `iris` service being started first.
- Exposes HTTP on `$WEBGATEWAY_PORT_HTTP` (→ 80) and HTTPS on `$WEBGATEWAY_PORT_HTTPS` (→ 443).
- Mounts `./webgateway/` for CSP gateway configuration (`CSP.conf` and `CSP.ini`).
- Restarts automatically unless manually stopped.

Both services share the default Docker network. Port values are configured via environment variables (e.g. in a `.env` file).

