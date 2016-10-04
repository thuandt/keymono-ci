FROM golang:1.7

MAINTAINER Thuan Duong <thuandt26@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV CLOUDSDK_VERSION 128.0.0

RUN apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends curl rsync expect tcl tcl-tclreadline && \
    curl https://glide.sh/get | bash && \
    go get -u github.com/alecthomas/gometalinter \
              github.com/golang/lint/golint \
              github.com/kisielk/errcheck \
              github.com/ckaznocha/protoc-gen-lint && \
    curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-"${CLOUDSDK_VERSION}"-linux-x86_64.tar.gz | tar -xz -C /opt/ && \
    /opt/google-cloud-sdk/bin/gcloud --quiet components install kubectl && \
    echo "source '/opt/google-cloud-sdk/path.bash.inc'" >> /root/.bashrc && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends nodejs
