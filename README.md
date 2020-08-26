# Protobuf-manage-api

## Stub generation
We are going to generate stub code to different languages(Java, Golang)

## Code distribution
We are going to distribute the API generated code to different languages(Java, Golang)

## OpenAPI definition 
We reads protobuf service definitions and generates service definition files.
These files can then be used by the Swagger-UI project to display the API and Swagger-Codegen to generate clients in various languages.

## HTTP Client SDKs
We use the service definition files along with Swagger-Codegen to generate HTTP clients for the service in Java and Golang.

## HTTP Client UI
We use the service definition files along with Swagger-UI project to display the HTTP API version

### Swagger-UI
- Run the services/apihttp/main.go
- Access https://localhost:8081/?def-file=./definition/book/v1/books.swagger.json

## Quality assurance 
We guarantee the quality of the API by using the project Buf to ensure that the API follows a 
code style

## Back compatibility
We guarantee back-compatibility of the API by using the project Buf to ensure that the API 
changes doesn't break the existing contract.

## Use the built Docker image
We are sharing a docker image with everything required in this project

```
docker run -it -v "$(pwd):/workspace" -v "$HOME"/.m2:/root/.m2  -w /workspace   apssouza/proto-api-manager
make generate
make install
```

If you prefer to build a local image `docker build . -f assets/Dockerfile -t apssouza/proto-api-manager` 



