# Modern API management
This project tries to provide a modern approach to manage APIs 
combining Protobuf and OpenAPI specification.
 
The project tries to address the following challenges:
- Contract definitions
- Contract compatibility enforcement 
- Contract versioning
- OpenAPI definition generation
- Stub generation to different languages
- Client SDK generation to different languages
- Swagger-UI to display the HTTP API
- API management guideline 
- ETC


========================================================================
## Free Advanced Java Course
I am the author of the [Advanced Java for adults course](https://www.udemy.com/course/advanced-java-for-adults/?referralCode=8014CCF0A5A931ADED5F). This course contains advanced and not conventional lessons. In this course, you will learn to think differently from those who have a limited view of software development. I will provoke you to reflect on decisions that you take in your day to day job, which might not be the best ones. This course is for middle to senior developers and we will not teach Java language features but how to lead complex Java projects. 

This course's lectures are based on a Trading system, an opensource project hosted on my [Github](https://github.com/apssouza22/trading-system).

========================================================================


## Get started

```
make generate
make install
```

### Use the built Docker image
We are sharing a docker image with everything required by this project

```
docker run -it -v "$(pwd):/workspace" -v "$HOME"/.m2:/root/.m2  -w /workspace   apssouza/proto-api-manager
make generate
make install
```

If you prefer to build a local image `docker build . -f assets/Dockerfile -t apssouza/proto-api-manager` 


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

## API management guideline 
Check out a [guideline](https://github.com/apssouza22/modern-api-management/tree/master/guidelines) to help manage the APIs in a microservice environment

## Microservice example
Check out 2 microservices examples inside `./services` to get inspired. Book microservice is in Golang and
Shelf microservice is in Java.

