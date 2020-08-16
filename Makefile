generate:
	bin/java-gen.sh && \
	bin/go-gen.sh && \
	bin/swagger-gen.sh && \
	bin/swagger-assets-package.sh

install:
	bin/java-package.sh && \
    bin/java-install.sh && \
    bin/go-deploy.sh
