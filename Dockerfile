FROM jenkinsci/jenkins

USER root
RUN set -ex \
        && userdel jenkins \
        && groupadd -g 9001 jenkins \
        && useradd -d "${JENKINS_HOME}" -u 9001 -g jenkins -s /bin/bash jenkins \
        && chown -R jenkins "${JENKINS_HOME}" /usr/share/jenkins/ref
RUN sh -ex \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            g++ \
            gcc \
            libc6-dev \
            make \
            pkg-config \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/

# golang
ENV GOLANG_VERSION 1.8.3
ENV GOREL_SHA256 1862f4c3d3907e59b04a757cfda0ea7aa9ef39274af99a784f5be843c80c6772

RUN set -eux \
        && wget -O go.tgz https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz \
        && echo "${GOREL_SHA256} *go.tgz" | sha256sum -c - \
        && tar -C /usr/local -xzf go.tgz \
        && rm -f go.tgz \
        && /usr/local/go/bin/go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get -u github.com/golang/lint/golint

# timezone
RUN echo 'Asia/Tokyo' > /etc/timezone

# docker
RUN curl -L https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xzf - docker/docker \
 && mv docker/docker /usr/local/bin/docker \
 && curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose \
 && chmod -v +x /usr/local/bin/docker /usr/local/bin/docker-compose

USER jenkins
