# Build with
#     docker build  -t vanitygen:latest .
#Once, built one can run it as follows:
#     docker run -it vanitygen /bin/bash -c "vanitygen 1dock"

#This version because libssl1.0 is available there and vanitygen uses t
FROM ubuntu:18.04

######### Optional things to adjust ########
# Maxing out processors was killing my docker instance, so here's a place to 
# manually set how many you want to use.
ARG NUM_PROCESSES=1 

## Reduce complaints 
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
	apt-get -y install apt-utils aptitude && \
	aptitude -y update && \
	aptitude -y full-upgrade

#Configure timezone, default to LA because West Coast Best Coast
ARG TZ='America/Los_Angeles'
RUN apt-get -y install tzdata && \
	ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo ${TZ} > /etc/timezone && \
	dpkg-reconfigure tzdata

## build utilities
RUN aptitude -y install \
				build-essential \
				git \
				libpcre-ocaml \
				libpcre++-dev \
				libssl1.0-dev 

WORKDIR /opt

RUN git config --global http.postBuffer 524288000  

RUN git clone -v -j${NUM_PROCESSES} https://github.com/samr7/vanitygen

WORKDIR /opt/vanitygen

RUN make -j ${NUM_PROCESSES}

## Done installing packages, clean up after ourselves
RUN apt-get autoremove && \
	apt-get autoclean && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	aptitude clean && \
	aptitude autoclean
