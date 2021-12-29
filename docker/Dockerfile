
FROM openjdk:8-jdk-alpine
MAINTAINER Alma Consumer Digikehitys <il-verkkotiimi@almamedia.fi>

# working directory for gatling
WORKDIR /opt

# gatling version
ARG gatling_version=3.7.2
ENV GATLING_VERSION=$gatling_version

# create directory for gatling install
RUN mkdir -p gatling

# install gatling
RUN apk add --update wget bash libc6-compat
RUN mkdir -p /tmp/downloads
RUN wget -q -O /tmp/downloads/gatling-$GATLING_VERSION.zip \
    https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/$GATLING_VERSION/gatling-charts-highcharts-bundle-$GATLING_VERSION-bundle.zip
RUN mkdir -p /tmp/archive && cd /tmp/archive && \
    unzip /tmp/downloads/gatling-$GATLING_VERSION.zip && \
    mv /tmp/archive/gatling-charts-highcharts-bundle-$GATLING_VERSION/* /opt/gatling/ && \
    rm -rf /tmp/*

# change context to gatling directory
WORKDIR  /opt/gatling

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
