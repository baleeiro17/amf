FROM golang:1.14.4-stretch AS builder

LABEL maintainer="Luiz Felipe Cunha"

RUN apt-get update && apt-get -y install gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
RUN apt-get clean


RUN cd $GOPATH/src \
    && git clone --recursive -b v3.0.4 -j 33 https://github.com/free5gc/free5gc.git \
    && cd free5gc \
    && go mod download

COPY Makefile $GOPATH/src/free5gc/Makefile
COPY . $GOPATH/src/amf

RUN cd $GOPATH/src/free5gc \
    && make amf


RUN ls /go/src/free5gc/bin
# Alpine is used for debug purpose. You can use scratch for a smaller footprint.
FROM alpine

ENV F5GC_MODULE amf
WORKDIR /free5gc

RUN mkdir -p config/ support/TLS/ log/ ${F5GC_MODULE}/

# Copy executables
COPY --from=builder /go/src/free5gc/bin/${F5GC_MODULE} ./${F5GC_MODULE}

# Copy configuration files (not used for now)
COPY --from=builder /go/src/free5gc/config/* ./config/

# Copy executable and default certs
COPY --from=builder /go/src/free5gc/support/TLS/${F5GC_MODULE}.pem ./support/TLS/
COPY --from=builder /go/src/free5gc/support/TLS/${F5GC_MODULE}.key ./support/TLS/


ARG DEBUG_TOOLS

# Install debug tools ~ 100MB (if DEBUG_TOOLS is set to true)
RUN if [ "$DEBUG_TOOLS" = "true" ] ; then apk add -U vim strace net-tools curl netcat-openbsd ; fi

# Move to the binary path
WORKDIR /free5gc/${F5GC_MODULE}

# Config files volume
VOLUME [ "/free5gc/config" ]

# Certificates (if not using default) volume
VOLUME [ "/free5gc/support/TLS" ]

# Exposed ports
EXPOSE 29518
