package main

import (
	"crypto/tls"
	"github.com/apssouza/openapi/certtls"
	_ "github.com/apssouza22/protobuf-gen-code/statik"
	"github.com/gorilla/mux"
	"github.com/rakyll/statik/fs"
	"github.com/sirupsen/logrus"
	grpc_client "gitlab.com/deem-devops/phoenix/grpc-go/client"
	"google.golang.org/grpc"
	"mime"
	"net/http"
	"strings"
)

const addr = "0.0.0.0:8081"

func StartHTTPServer(builder grpc_client.GrpcClientBuilder) {
	conn, err := builder.GetConn("localhost", "8080")
	if err != nil {
		logrus.Fatal(err)
	}
	searchHandler := getSvcReqHandler(conn)
	swaggerHandler := getSwaggerHandler()

	gwServer := &http.Server{
		Addr:    addr,
		Handler: getRequestHandler(searchHandler, swaggerHandler),
	}
	gwServer.TLSConfig = &tls.Config{
		Certificates: []tls.Certificate{certtls.Cert},
	}
	logrus.Infof("Http server started on port 8081")
	gwServer.ListenAndServeTLS("", "")

}

// getSwaggerHandler serves an Swagger UI.
func getSwaggerHandler() http.Handler {
	mime.AddExtensionType(".svg", "image/svg+xml")

	statikFS, err := fs.New()
	if err != nil {
		logrus.Panic("creating Swagger filesystem: " + err.Error())
	}
	return http.FileServer(statikFS)
}

func getSvcReqHandler(conn *grpc.ClientConn) *mux.Router {
	router := mux.NewRouter().StrictSlash(true)
	//apiHandler := book.GetServiceReqHandler(conn)
	//router.HandleFunc("/apis/v1/bookStore.ListBooks", apiHandler.ListBooks).Methods("POST")
	//router.HandleFunc("/apis/v1/bookStore.CreateBook", apiHandler.CreateBook).Methods("POST")
	return router
}

func getRequestHandler(searchHandler http.Handler, swaggerHandler http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/apis") {
			searchHandler.ServeHTTP(w, r)
			return
		}
		swaggerHandler.ServeHTTP(w, r)
	}
}
