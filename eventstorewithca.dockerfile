from eventstore/eventstore:21.10.0-buster-slim as es
USER root
copy certs/ca/ca.crt /usr/local/share/ca-certificates/ivendi.crt

RUN chmod 600 /usr/local/share/ca-certificates/ivendi.crt
RUN update-ca-certificates --fresh
RUN apt update && apt install dnsutils net-tools -yq
