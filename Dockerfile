# Building
# --------
FROM golang:1.11-alpine as builder
MAINTAINER gregdhill <greg.hill@monax.io>

ARG REPO=$GOPATH/src/github.com/gregdhill/bridge
COPY . $REPO
WORKDIR $REPO

RUN go build --ldflags '-extldflags "-static"' -o bin/bridge

# Deployment
# ----------
FROM alpine:3.8

ARG REPO=/go/src/github.com/gregdhill/bridge
COPY --from=builder $REPO/bin/* /usr/local/bin/

RUN apk add --no-cache ca-certificates

ENTRYPOINT [ "bridge" ]
