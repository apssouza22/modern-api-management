generate:
# 	bin/java-gen.sh
	bin/go-gen.sh
	bin/swagger-gen.sh
	bin/statik-gen.sh

install:
	go get \
		github.com/golang/protobuf/protoc-gen-go \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
		github.com/rakyll/statik
