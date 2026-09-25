FROM ubuntu:latest
LABEL maintainer="Tan Jing Yu <leon0912tan@gmail.com>"

USER root
COPY ./web-server.bash /
RUN chmod 755 /web-server.bash

# Combine update and install, use apt-get, and clean up cache
RUN apt-get update && apt-get install -y \
    bash \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

USER nobody

ENTRYPOINT [ "/web-server.bash" ]