## Stub generation
We are going to generate stub code to different languages(Java, Golang)

## Code distribution
We are going to distribute the API generated code to different languages(Java, Golang)

## Document generation
We are going to use the OpenAPI with Swagger to expose our API documentation as well as consume our 
gRPC through the Swagger UI.

## Quality assurance 
We are going to guarantee the quality of the API by using the project Buf to ensure that the API follows a 
code style

## Back compatibility
We are going to guarantee back-compatibility of the API by using the project Buf to ensure that the API 
changes doesn't break the existing contract.


docker run -it -v "$(pwd):/workspace" -v "$HOME"/.m2:/root/.m2  -w /workspace   proto-api
 
$ docker run -it --rm --name my-maven-project -v "$PWD":/usr/src/app \
 -v "$HOME"/.m2:/root/.m2 -w /usr/src/app maven:3.2-jdk-7 mvn clean install
