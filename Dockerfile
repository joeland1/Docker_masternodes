FROM debian:latest
WORKDIR /root
RUN apt update && apt install tor wget jq xxd -y

COPY scripts bin .

RUN chmod +x *.sh

RUN mkdir -p data params

EXPOSE 56740
