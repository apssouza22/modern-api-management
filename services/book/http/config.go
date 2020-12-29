package http

import (
	"crypto/tls"
	"github.com/apssouza/bookservice/certtls"
	"github.com/apssouza/bookservice/http/v1"
	grpc_client "github.com/apssouza22/grpc-production-go/client"
	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"google.golang.org/grpc"
	"net/http"
)

const httpAddr = "localhost:50051"
const grpcAddr = "localhost:50053"

func StartHTTPServer(builder grpc_client.GrpcClientConnBuilder) {
	conn, err := builder.GetConn(grpcAddr)
	if err != nil {
		logrus.Fatal(err)
	}
	router := mux.NewRouter().StrictSlash(true)
	setEndpointHandlers(conn, router)
	listenAndServ(router)
}

func listenAndServ(router *mux.Router) {
	gwServer := &http.Server{
		Addr:    httpAddr,
		Handler: router,
	}
	gwServer.TLSConfig = &tls.Config{
		Certificates: []tls.Certificate{certtls.Cert},
	}
	logrus.Infof("Http server started on port %s", httpAddr)
	gwServer.ListenAndServeTLS("", "")
}

func setEndpointHandlers(conn *grpc.ClientConn, router *mux.Router) {
	apiHandler := httpv1.GetServiceReqHandler(conn)
	router.HandleFunc("/apis/v1/BookStore.ListBooks", apiHandler.ListBooks).Methods("POST")
	router.HandleFunc("/apis/v1/BookStore.CreateBook", apiHandler.CreateBook).Methods("POST")
}
