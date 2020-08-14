package httputil

import (
	"encoding/json"
	"fmt"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/proto"
	"google.golang.org/grpc/status"
	"io/ioutil"
	"net/http"
	"strings"
)

func GetProxy(w http.ResponseWriter, r *http.Request, request proto.Message) *ServiceProxy {
	proxy := &ServiceProxy{}
	proxy.SetResponseWriter(w)
	proxy.SetSourceRequest(r)
	proxy.SetDestRequest(request)
	return proxy
}

type ServiceProxy struct {
	err            error
	serviceRequest func(request proto.Message) (proto.Message, error)
	writer         http.ResponseWriter
	destRequest    proto.Message
	sourceRequest  *http.Request
}

func (b *ServiceProxy) SetDestRequest(request proto.Message) {
	b.destRequest = request
}

func (b *ServiceProxy) SetSourceRequest(request *http.Request) {
	b.sourceRequest = request
}

func (b *ServiceProxy) SetServiceRequest(svcRequest func(request proto.Message) (proto.Message, error)) *ServiceProxy {
	b.serviceRequest = svcRequest
	return b
}

func (b *ServiceProxy) Call() {
	b.writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	err := unmarshal(b.writer, b.sourceRequest, b.destRequest)
	if err != nil {
		return
	}
	resp, err := b.serviceRequest(b.destRequest)
	if err != nil {
		handleErrorResp(b.writer, err)
		return
	}
	b.writer.WriteHeader(http.StatusOK)
	json.NewEncoder(b.writer).Encode(resp)
}

func (b *ServiceProxy) SetResponseWriter(w http.ResponseWriter) {
	b.writer = w
}

func handleErrorResp(w http.ResponseWriter, err error) {
	w.WriteHeader(http.StatusBadRequest)
	st := status.Convert(err)
	json.NewEncoder(w).Encode(st)
	return
}

func unmarshal(w http.ResponseWriter, r *http.Request, request proto.Message) error {
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return fmt.Errorf("failed to read body: %w", err)
	}
	jsonpb.Unmarshal(strings.NewReader(string(reqBody)), request)
	return nil
}
