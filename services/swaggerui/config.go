package main

import (
	"crypto/tls"
	"github.com/apssouza/openapi/certtls"
	_ "github.com/apssouza22/protobuf-gen-code/statik"
	"github.com/rakyll/statik/fs"
	"github.com/sirupsen/logrus"
	"mime"
	"net/http"
)

const addr = "0.0.0.0:8081"

func StartHTTPServer() {
	swaggerHandler := getSwaggerHandler()

	gwServer := &http.Server{
		Addr:    addr,
		Handler: getRequestHandler(swaggerHandler),
	}
	gwServer.TLSConfig = &tls.Config{
		Certificates: []tls.Certificate{certtls.Cert},
	}
	logrus.Infof("Http server started on %s", addr)
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

func getRequestHandler(swaggerHandler http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		swaggerHandler.ServeHTTP(w, r)
	}
}
