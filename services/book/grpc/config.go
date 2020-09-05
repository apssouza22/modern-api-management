package grpc

import (
	"fmt"
	grpcv1 "github.com/apssouza/bookservice/grpc/v1"
	grpc_client "github.com/apssouza22/grpc-production-go/client"
	"github.com/apssouza22/grpc-production-go/grpcutils"
	grpc_server "github.com/apssouza22/grpc-production-go/server"
	bookv1 "github.com/apssouza22/protobuf-gen-code/book/v1"
	shelfv1 "github.com/apssouza22/protobuf-gen-code/shelf/v1"
	"github.com/sirupsen/logrus"
	"google.golang.org/grpc"
)

func ServiceRegister(builder grpc_client.GrpcClientConnBuilder) (func(s *grpc.Server), error) {
	shelfConn, err := builder.GetConn("localhost:50052")
	if err != nil {
		return nil, err
	}
	shelfClient := shelfv1.NewShelfServiceClient(shelfConn)
	hssServer := grpcv1.NewReqHandler(shelfClient)
	if err != nil {
		return nil, err
	}
	return func(s *grpc.Server) {
		bookv1.RegisterBookstoreServiceServer(s, hssServer)
	}, nil
}

// Initializes the grpc server but does not start or add services.
func GetGrpcServer() grpc_server.GrpcServer {
	builder := grpc_server.GrpcServerBuilder{}
	builder.SetUnaryInterceptors(grpcutils.GetDefaultUnaryServerInterceptors())
	builder.EnableReflection(true)
	builder.DisableDefaultHealthCheck(true)
	return builder.Build()
}

// StartServer Runs the gRPC server - it does not return unless server shuts down.
func StartServer(grpcServer grpc_server.GrpcServer, f func()) error {
	err := grpcServer.Start("localhost:50053")
	if err != nil {
		return fmt.Errorf("GRPC server failed to start %+v", err)
	}
	f()
	grpcServer.AwaitTermination(func() {
		logrus.Warn("Shutting down the server")
	})
	return err
}
