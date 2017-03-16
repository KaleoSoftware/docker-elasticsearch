# Elasticsearch by Kaleo Software
# See https://github.com/phusion/baseimage-docker for how to use this base image
FROM phusion/baseimage:latest

ENV \
    ES_VERSION=5.2.2 \
    ES_JAVA_OPTS="-Xms512m -Xmx512m" \
    ES_PLUGINS_INSTALL="x-pack" \
    CLUSTER_NAME=elasticsearch-default \
    NODE_MASTER=true \
    NODE_DATA=true \
    NODE_INGEST=true \
    NETWORK_HOST=_site_ \
    HTTP_ENABLE=true \
    HTTP_CORS_ENABLE=true \
    HTTP_CORS_ALLOW_ORIGIN=* \
    XPACK_SECURITY=false \
    NUMBER_OF_MASTERS=1 \
    NUMBER_OF_SHARDS=1 \
    NUMBER_OF_REPLICAS=0 \
    MAX_LOCAL_STORAGE_NODES=1 \
    DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/share/elasticsearch/bin:$PATH \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

# Volume for Elasticsearch data
VOLUME ["/data"]

EXPOSE 9200 9300

# Update ubuntu and install java
RUN \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections) \
  && add-apt-repository -y ppa:webupd8team/java \
  && apt-get update \
  && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
  && apt-get install -y oracle-java8-installer \
  && apt-get clean \
  && rm -rf /var/cache/oracle-jdk8-installer \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Elasticsearch manually for more control.
RUN \
  (curl -Lskj https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz | gunzip -c - | tar xf - ) \
  && mv elasticsearch-$ES_VERSION /usr/share/elasticsearch \
  && rm -rf $(find /usr/share/elasticsearch | egrep "(\.(exe|bat)$)")

# Copy configuration
COPY config /usr/share/elasticsearch/config

RUN \
  useradd --groups sudo elasticsearch \
  && chown -R elasticsearch:elasticsearch /usr/share/elasticsearch /data \
  && (echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers)

# phusion special way of running things
RUN mkdir /etc/service/elasticsearch
ADD bin/run /etc/service/elasticsearch/run

CMD ["/sbin/my_init"]
