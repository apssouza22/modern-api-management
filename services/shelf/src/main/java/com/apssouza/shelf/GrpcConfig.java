package com.apssouza.shelf;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import com.apssouza.grpc.server.GrpcServer;
import com.apssouza.grpc.server.GrpcServerBuilder;
import com.apssouza.grpc.server.HealthCheckService;
import com.apssouza.grpc.serverinterceptors.CancelledRequestInterceptor;
import com.apssouza.grpc.serverinterceptors.StopwatchServerInterceptor;
import com.apssouza.grpc.serverinterceptors.UnexpectedExceptionInterceptor;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.grpc.BindableService;
import io.grpc.ServerInterceptor;

@Configuration
@ComponentScan
public class GrpcConfig {
    private List<BindableService> bindableServiceList;

    public GrpcConfig(final List<BindableService> bindableServiceList) {
        this.bindableServiceList = bindableServiceList;
    }

    @Bean
    GrpcServer grpcServer(@Value("${grpc.server.port}") Integer port) {
        bindableServiceList.add(new HealthCheckService());
        GrpcServerBuilder builder = GrpcServerBuilder.port(port);
        return  builder.services(bindableServiceList)
                .fixedThreadPool(4)
                .maxConnectionAge(5, TimeUnit.MINUTES)
                .interceptors(getInterceptors())
                .build();
    }

    private static List<ServerInterceptor> getInterceptors() {
        return Arrays.asList(
                new CancelledRequestInterceptor(),
                new StopwatchServerInterceptor(),
                new UnexpectedExceptionInterceptor()
        );
    }

}
