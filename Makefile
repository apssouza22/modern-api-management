generate:
	bin/java-gen.sh && \
	bin/go-gen.sh && \
	bin/swagger-gen.sh && \
	bin/statik-gen.sh

install:
	bin/java-package.sh && \
    bin/java-install.sh && \
    bin/go-install.sh
