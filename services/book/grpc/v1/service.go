package grpcv1

import (
	"context"
	"github.com/apssouza22/protobuf-gen-code/book/v1"
	shelfv1 "github.com/apssouza22/protobuf-gen-code/shelf/v1"
)

func NewReqHandler(shelfConn shelfv1.ShelfServiceClient) bookv1.BookstoreServiceServer {
	return &BookServiceImpl{shelfConn: shelfConn}
}

type BookServiceImpl struct {
	shelfConn shelfv1.ShelfServiceClient
}

func (b BookServiceImpl) ListBooks(ctx context.Context, request *bookv1.ListBooksRequest) (*bookv1.ListBooksResponse, error) {
	// Call to the Shelf microservice
	//b.shelfConn.ListShelves(ctx, &shelfv1.ListShelvesRequest{})
	var books []*bookv1.CreateBookResponse
	books = append(books, &bookv1.CreateBookResponse{
		Id:     1,
		Author: "Alex Souza",
		Title:  "Modern api management",
	})
	return &bookv1.ListBooksResponse{
		Books: books,
	}, nil
}

func (b BookServiceImpl) CreateBook(ctx context.Context, request *bookv1.CreateBookRequest) (*bookv1.CreateBookResponse, error) {
	panic("implement me")
}

func (b BookServiceImpl) GetBook(ctx context.Context, request *bookv1.GetBookRequest) (*bookv1.GetBookResponse, error) {
	panic("implement me")
}

func (b BookServiceImpl) DeleteBook(ctx context.Context, request *bookv1.DeleteBookRequest) (*bookv1.DeleteBookResponse, error) {
	panic("implement me")
}
