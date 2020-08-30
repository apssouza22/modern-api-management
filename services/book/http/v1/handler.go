package httpv1

import (
	"github.com/apssouza/bookservice/httputil"
	"github.com/apssouza22/protobuf-gen-code/book/v1"
	"github.com/golang/protobuf/proto"
	"google.golang.org/grpc"
	"net/http"
)

func GetServiceReqHandler(conn *grpc.ClientConn) BookStoreService {
	client := bookv1.NewBookstoreServiceClient(conn)
	return BookStoreService{client: client}
}

type BookStoreService struct {
	client bookv1.BookstoreServiceClient
	bookv1.BookstoreServiceServer
}

// Creates a new book.
func (h BookStoreService) CreateBook(w http.ResponseWriter, r *http.Request) {
	request := &bookv1.CreateBookRequest{}
	proxy := httputil.GetProxy(w, r, request)
	proxy.SetServiceRequest(func(request proto.Message) (proto.Message, error) {
		return h.client.CreateBook(r.Context(), request.(*bookv1.CreateBookRequest))
	})
	proxy.Call()
}

// Returns a list of books on a shelf.
func (h BookStoreService) ListBooks(w http.ResponseWriter, r *http.Request) {
	request := &bookv1.ListBooksRequest{}
	proxy := httputil.GetProxy(w, r, request)
	proxy.SetServiceRequest(func(request proto.Message) (proto.Message, error) {
		return h.client.ListBooks(r.Context(), request.(*bookv1.ListBooksRequest))
	})
	proxy.Call()
}
