FROM tuliptools/tplustezos:sandbox as tezbase
FROM ligolang/ligo:next as ligo
FROM codercom/code-server:v2 as coder


FROM ubuntu:19.04
USER root


RUN apt-get update && apt-get install -y \
	openssl \
	net-tools \
	git \
	locales \
	sudo \
	dumb-init \
	vim \
	curl \
	wget

RUN locale-gen en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder
RUN mkdir -p /home/coder/project
WORKDIR /home/coder/project

USER root
COPY --from=coder /usr/local/bin/code-server /usr/local/bin/code-server
COPY --from=ligo /home/opam/.opam/4.07/bin/* /usr/local/bin/
COPY --from=tezbase /usr/local/bin/tezos* /usr/local/bin/


RUN apt update && apt-get install -y libgmp-dev libev-dev libusb-dev libhidapi-dev
RUN echo -e "http\t80/tcp\twww\t# WorldWideWeb HTTP" > /etc/services
RUN apt-get update && \
 yes | apt-get install -y htop aria2 wget curl git pydf mtr ack-grep nano unzip
RUN aria2c https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip && \
 unzip exa-linux-x86_64-0.9.0.zip && \
 cp exa-linux-x86_64 /usr/local/bin/exa && rm *

RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get install -y gcc g++ make nodejs haproxy runit telnet inetutils-ping
RUN echo "http\t80/tcp\twww\t# WorldWideWeb HTTP" > /etc/services
RUN curl -s https://SmartPy.io/SmartPyBasic/SmartPy.sh > SmartPy.sh && chmod +x ./SmartPy.sh && ./SmartPy.sh local-install / && rm SmartPy.sh

COPY ./configs/haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./configs/bash /home/coder/.bashrc
COPY ./configs/bash /root/.bashrc

COPY ./entrypoint.sh /entrypoint.sh

USER root
EXPOSE 8080
ENTRYPOINT ["dumb-init", "/entrypoint.sh"]