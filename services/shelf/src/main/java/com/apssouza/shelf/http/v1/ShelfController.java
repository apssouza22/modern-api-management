package com.apssouza.shelf.http.v1;

import com.apssouza.api.bookstore.shelf.v1.CreateShelfRequest;
import com.apssouza.api.bookstore.shelf.v1.CreateShelfResponse;
import com.apssouza.api.bookstore.shelf.v1.ShelfServiceGrpc;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.health.v1.HealthGrpc;

@RestController
public class ShelfController {

    private final ShelfServiceGrpc.ShelfServiceBlockingStub client;

    public ShelfController(final ShelfServiceGrpc.ShelfServiceBlockingStub client) {
        this.client = client;
    }

    @PostMapping("/api/v1/shelfService.CreateShelf")
    public CreateShelfResponse createShelf(@RequestBody CreateShelfRequest request) {
        return client.createShelf(request);
    }

}
