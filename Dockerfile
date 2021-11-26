FROM debian:latest
WORKDIR /root
RUN apt update && apt install tor wget -y

COPY scripts bin .

RUN mkdir -p data params

