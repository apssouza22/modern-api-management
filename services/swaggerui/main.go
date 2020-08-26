package main

import (
	"context"
	grpc_client "gitlab.com/deem-devops/phoenix/grpc-go/client"
	"gitlab.com/deem-devops/phoenix/grpc-go/util"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	clientBuilder := grpc_client.GrpcClientBuilder{}
	clientBuilder.WithInsecure()
	clientBuilder.WithContext(ctx)
	clientBuilder.WithUnaryInterceptors(util.GetDefaultUnaryClientInterceptors())
	StartHTTPServer(clientBuilder)
}
