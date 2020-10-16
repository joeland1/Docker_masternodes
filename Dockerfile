FROM ubuntu:18.04
ENV SHELL /bin/bash
CMD ["/bin/bash"]

ARG COIN="dogecash"

RUN mkdir -p /home/$COIN
RUN mkdir -p /home/$COIN/.$COIN
WORKDIR /home/$COIN

COPY setup.sh .
COPY dogecashd .
COPY dogecash-cli .

RUN chmod +x .

ADD . /usr/local/bin

RUN useradd -ms /bin/bash $COIN

USER $COIN

EXPOSE 56740
