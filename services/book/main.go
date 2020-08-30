package main

import (
	"context"
	"github.com/apssouza/bookservice/http"
	grpc_client "github.com/apssouza22/grpc-production-go/client"
	"github.com/apssouza22/grpc-production-go/grpcutils"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	clientBuilder := grpc_client.GrpcClientBuilder{}
	clientBuilder.WithInsecure()
	clientBuilder.WithContext(ctx)
	clientBuilder.WithUnaryInterceptors(grpcutils.GetDefaultUnaryClientInterceptors())
	http.StartHTTPServer(clientBuilder)
}
