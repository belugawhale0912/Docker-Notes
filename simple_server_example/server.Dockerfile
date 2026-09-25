FROM ubuntu
LABEL maintainer="Tan Jing Yu <leon0912tan@gmail.com>"

USER root
COPY ./server.bash /

RUN chmod 755 /server.bash
RUN apt -y update
RUN apt -y install bash

USER nobody

ENTRYPOINT [ "/server.bash" ]
