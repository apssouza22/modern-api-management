package com.apssouza.shelf;

import com.apssouza.grpc.server.GrpcServer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

import java.io.IOException;


@SpringBootApplication
public class App {

    public static void main(String[] args)throws IOException, InterruptedException {
        SpringApplication springApplication = new SpringApplication(App.class, GrpcConfig.class);
        ConfigurableApplicationContext context = springApplication.run(args);
        GrpcServer grpcServer = context.getBean(GrpcServer.class);
        grpcServer.start();
    }

}
