FROM golang:1.14.4-stretch AS builder

LABEL maintainer="Luiz Felipe Cunha"

RUN apt-get update && apt-get -y install gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
RUN apt-get clean


RUN cd $GOPATH/src \
    && git clone --recursive -b v3.0.4 -j 33 https://github.com/free5gc/free5gc.git \
    && cd free5gc \
    && go mod download

WORKDIR $GOPATH/src/amf
COPY go.mod .
RUN go mod download

COPY communication communication
COPY config config
COPY consumer consumer
COPY context context
COPY eventexposure eventexposure
COPY factory factory
COPY gmm gmm
COPY httpcallback httpcallback
COPY location location
COPY logger logger
COPY mt mt
COPY nas nas
COPY ngap ngap
COPY oam oam
COPY producer producer
COPY service service
COPY util util
COPY version version
COPY amf.go .
COPY Makefile .

RUN make amf

# Alpine is used for debug purpose. You can use scratch for a smaller footprint.
FROM alpine

ENV F5GC_MODULE amf
WORKDIR /amf

RUN mkdir -p config/ support/TLS/ log/ ${F5GC_MODULE}/

# Copy executables
COPY --from=builder /go/src/amf/bin/${F5GC_MODULE} ./${F5GC_MODULE}

# Copy executable and default certs
COPY --from=builder /go/src/free5gc/support/TLS/${F5GC_MODULE}.pem ./support/TLS/
COPY --from=builder /go/src/free5gc/support/TLS/${F5GC_MODULE}.key ./support/TLS/


ARG DEBUG_TOOLS

# Install debug tools ~ 100MB (if DEBUG_TOOLS is set to true)
RUN if [ "$DEBUG_TOOLS" = "true" ] ; then apk add -U vim strace net-tools curl netcat-openbsd ; fi

# Move to the binary path
WORKDIR /amf/${F5GC_MODULE}

COPY -f entrypoint.sh ./
RUN chmod +x entrypoint.sh


# Config files volume
VOLUME [ "/amf/config" ]

# Certificates (if not using default) volume
VOLUME [ "/amf/support/TLS" ]

# Exposed ports
EXPOSE 29518

ENTRYPOINT [ "entrypoint.sh" ]
