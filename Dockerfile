FROM jenkins:alpine
MAINTAINER yokogawa-k "yokogawa-k@klab.com"

USER root
RUN set -ex \
        && delgroup ping \
        && addgroup -g 999 docker \
        && deluser jenkins \
        && addgroup -g 9001 jenkins \
        && adduser -h "${JENKINS_HOME}" -u 9001 -G jenkins -s /bin/bash -D jenkins \
        && addgroup jenkins docker
RUN sh -ex \
        && apk add --no-cache \
            make \
            go \
            go-tools \
            tzdata \
        && cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
        && apk del tzdata

# golang
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# timezone
RUN echo 'Asia/Tokyo' > /etc/timezone

# docker
RUN curl -L https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xzf - docker/docker \
 && mv docker/docker /usr/local/bin/docker \
 && curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose \
 && chmod -v +x /usr/local/bin/docker /usr/local/bin/docker-compose

USER jenkins
