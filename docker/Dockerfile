FROM openjdk:8-jdk-alpine
ARG GATLING_VERSION
# Gatling is a highly capable load testing tool.
#
# Documentation: https://gatling.io/docs/3.0/
# Cheat sheet: https://gatling.io/docs/3.0/cheat-sheet/
MAINTAINER Alma Consumer Digikehitys <il-verkkotiimi@almamedia.fi>

# working directory for gatling
WORKDIR /opt

# create directory for gatling install
RUN mkdir -p gatling

# install gatling
RUN apk add --update wget bash libc6-compat
RUN mkdir -p /tmp/downloads
ADD ./downloads/gatling.zip /tmp/downloads/gatling.zip
RUN mkdir -p /tmp/archive
WORKDIR /tmp/archive
RUN unzip /tmp/downloads/gatling.zip
RUN mv /tmp/archive/gatling-charts-highcharts-bundle-$GATLING_VERSION/* /opt/gatling/

# change context to gatling directory
WORKDIR /opt/gatling
RUN rm -rf /tmp/*

# set directories below to be mountable from host
VOLUME ["/opt/gatling/conf", "/opt/gatling/results", "/opt/gatling/user-files"]

# set environment variables
ENV PATH /opt/gatling/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GATLING_HOME /opt/gatling

RUN apk update
RUN apk add python2 py2-pip
RUN pip install --upgrade pip
RUN pip install --upgrade awscli

ADD ./run-gatling.sh /opt/gatling/run-gatling.sh

ENTRYPOINT [ "/opt/gatling/run-gatling.sh" ]