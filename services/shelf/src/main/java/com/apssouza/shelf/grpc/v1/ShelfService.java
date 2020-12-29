package com.apssouza.shelf.grpc.v1;

import com.apssouza.api.bookstore.shelf.v1.CreateShelfRequest;
import com.apssouza.api.bookstore.shelf.v1.CreateShelfResponse;
import com.apssouza.api.bookstore.shelf.v1.ShelfServiceGrpc;

import org.springframework.stereotype.Service;

import io.grpc.stub.StreamObserver;

@Service
public class ShelfService extends ShelfServiceGrpc.ShelfServiceImplBase {

    public void createShelf(CreateShelfRequest request, StreamObserver<CreateShelfResponse> responseObserver) {
        CreateShelfResponse response = CreateShelfResponse
                .newBuilder()
                .setId(1)
                .build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }
}
