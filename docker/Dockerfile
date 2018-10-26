ARG GATLING_VERSION

FROM denvazh/gatling:$GATLING_VERSION
MAINTAINER Alma Consumer Digikehitys <il-verkkotiimi@almamedia.fi>

RUN apk update
RUN apk add python2 py2-pip
RUN pip install --upgrade pip
RUN pip install --upgrade awscli

ADD ./run-gatling.sh /opt/gatling/run-gatling.sh

ENTRYPOINT [ "/opt/gatling/run-gatling.sh" ]