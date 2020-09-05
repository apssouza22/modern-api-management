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
	"strings"
)

const httpAddr = "localhost:50051"
const grpcAddr = "localhost:50053"

func StartHTTPServer(builder grpc_client.GrpcClientConnBuilder) {
	conn, err := builder.GetConn(grpcAddr)
	if err != nil {
		logrus.Fatal(err)
	}
	searchHandler := getSvcReqHandler(conn)

	gwServer := &http.Server{
		Addr:    httpAddr,
		Handler: getRequestHandler(searchHandler),
	}
	gwServer.TLSConfig = &tls.Config{
		Certificates: []tls.Certificate{certtls.Cert},
	}
	logrus.Infof("Http server started on %s", httpAddr)
	gwServer.ListenAndServeTLS("", "")
}

func getSvcReqHandler(conn *grpc.ClientConn) *mux.Router {
	router := mux.NewRouter().StrictSlash(true)
	apiHandler := httpv1.GetServiceReqHandler(conn)
	router.HandleFunc("/apis/v1/BookStore.ListBooks", apiHandler.ListBooks).Methods("POST")
	router.HandleFunc("/apis/v1/BookStore.CreateBook", apiHandler.CreateBook).Methods("POST")
	return router
}

func getRequestHandler(searchHandler http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/apis") {
			searchHandler.ServeHTTP(w, r)
			return
		}
	}
}
