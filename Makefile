generate:
	bin/js-gen.sh ./protos 0.0.12 && \
	bin/java-gen.sh && \
	bin/go-gen.sh && \
	bin/swagger-gen.sh && \
	bin/swagger-assets-package.sh &&\
	bin/gen-sdk-clients.sh

install:
	bin/java-package.sh && \
    bin/java-install.sh && \
    bin/js-deploy.sh ./protos && \
    bin/go-deploy.sh
