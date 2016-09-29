FROM golang:1.7

MAINTAINER Thuan Duong <thuandt26@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends curl rsync expect tcl tcl-tclreadline && \
    curl https://glide.sh/get | sh && \
    go get -u github.com/alecthomas/gometalinter \
              github.com/golang/lint/golint \
              github.com/kisielk/errcheck
