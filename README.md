# Modern API management
This project try to provide a modern approach to manage APIs. The project address the following challenges:
- Contract definition using Protobuf
- Contract compatibility enforcement 
- Contract versioning
- OpenAPI definition generation
- Stub generation in different languages
- Client SDK generation in different languages
- Swagger-UI to display the HTTP API 
- ETC

## Stub generation
Generate stub code to different languages(Java, Golang)

```
./bin/go-gen.sh
./bin/java-gen.sh
```

## Code distribution
Share the API generated code to different languages(Java, Golang)

```
./bin/go-deploy.sh
./bin/java-package.sh
./bin/java-install.sh
```
## OpenAPI definition 
Reads protobuf service definitions and generates service definition files.
These files can then be used by the Swagger-UI project to display the API and Swagger-Codegen to generate clients in various languages.

```
./bin/swagger-gen.sh
./bin/swagger-assets-package.sh
```

## HTTP Client SDKs
Use the service definition files along with Swagger-Codegen to generate HTTP clients for the service in Java and Golang.

```
./bin/gen-sdk-clients.sh
```

## HTTP Client UI
Use the service definition files along with Swagger-UI project to display the HTTP API version

### Swagger-UI
- Run the services/swaggerui/main.go
- Access https://localhost:8081/?def-file=./definition/book/v1/books.swagger.json

## Quality assurance 
Guarantee the quality of the API by using the project Buf to ensure that the API follows a 
code style

This is done using Github actions. Check out the `.github/workflows/ci.yml`

## Back compatibility
Guarantee back-compatibility of the API by using the project Buf to ensure that the API 
changes doesn't break the existing contract.

This is done using Github actions. Check out the `.github/workflows/ci.yml`

## Use the built Docker image
We are sharing a docker image with everything required in this project

```
docker run -it -v "$(pwd):/workspace" -v "$HOME"/.m2:/root/.m2  -w /workspace   apssouza/proto-api-manager
make generate
make install
```

If you prefer to build a local image `docker build . -f assets/Dockerfile -t apssouza/proto-api-manager` 

## Microservice example
Check out 2 microservices examples inside `./services` to get inspired. Book microservice is in Golang and
Shelf microservice is in Java 

