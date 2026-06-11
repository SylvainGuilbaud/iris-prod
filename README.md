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

## INSTALLING THE SUPPLY CHAIN PACKAGE
The `iris.script` file is executed during the IRIS container build process. It performs the following steps:
1. Opens a connection to the IRIS instance and switches to the `SC` namespace.
2. Reads the ZPM repository credentials from a JSON file (`ipm.json`) and uses them to configure the ZPM repository for InterSystems packages.
3. Installs the `isc-supply-chain` package from the InterSystems Package Manager (IPM) repository.
This setup allows for a clean and repeatable deployment of the IRIS environment with the necessary application components pre-installed.

## BEFORE YOU START
- Ensure you have Docker and Docker Compose installed on your machine.
- Create a [`.env`](.env) file in the root of the project with the necessary environment variables (e.g. `IRIS_PORT`, `WEBGATEWAY_PORT_HTTP`, `WEBGATEWAY_PORT_HTTPS`).
- Place your IRIS license key in `iris/key/iris.key`
- Fill your credentials in the `iris/key/ipm.json` file with the necessary login information. You can retrieve your login and password from the [InterSystems Package Manager](https://ipm.intersystems.com/contents/ipm/install) website. You will find a model file in the repository in [`iris/key/ipm.json`](iris/key/ipm.json.to_replace_with_your_password), and you should replace the `login` and `password` fields with your actual credentials and rename the file to `ipm.json`. This file is used during the build process to authenticate with the IPM repository and install the required packages.
- Persistent data is stored in the `iris-data` Docker volume, so ensure it has the appropriate permissions for Docker to read/write. The ./start.sh and ./stop.sh scripts will handle starting and stopping the services, but you can also use `docker compose` commands directly if needed. The [`./start.sh`](./start.sh) handles the permissions for the iris-data volume, ensuring that the IRIS container can access it properly.

## STARTING THE SERVICES
Run the following command in the root of the project to start both the IRIS and Web Gateway services:
```bash
./start.sh
```
This will build the IRIS image (if not already built) and start both containers. You can access the IRIS instance on the specified port and the Web Gateway on the configured HTTP/HTTPS ports.

## STOPPING THE SERVICES
To stop the running containers, use the following command:
```bash
./stop.sh
```
