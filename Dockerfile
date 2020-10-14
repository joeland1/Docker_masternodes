FROM ubuntu:xenial-20200916

ARG COIN="dogecash"

RUN mkdir -p /home/$COIN
WORKDIR /home/$COIN

COPY setup.sh .

EXPOSE 56740
