FROM ubuntu:xenial-20200916

ARG COIN="dogecash"

RUN mkdir /home/$COIN
WORKDIR /home/$COIN

COPY setup.sh .
COPY README.md .

EXPOSE 56740
