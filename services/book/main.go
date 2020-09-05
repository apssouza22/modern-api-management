package main

import (
	"context"
	"github.com/apssouza/bookservice/grpc"
	"github.com/apssouza/bookservice/http"
	grpc_client "github.com/apssouza22/grpc-production-go/client"
	"github.com/apssouza22/grpc-production-go/grpcutils"
	"log"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	connBuilder := &grpc_client.GrpcConnBuilder{}
	connBuilder.WithInsecure()
	connBuilder.WithContext(ctx)
	connBuilder.WithUnaryInterceptors(grpcutils.GetDefaultUnaryClientInterceptors())
	register, err := grpc.ServiceRegister(connBuilder)
	if err != nil {
		log.Fatalf("Failed to register services. error = %v", err)
	}
	grpcServer := grpc.GetGrpcServer()
	grpcServer.RegisterService(register)
	grpc.StartServer(grpcServer, func() {
		http.StartHTTPServer(connBuilder)
	})
}
