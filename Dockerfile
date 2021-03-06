FROM ubuntu:trusty

MAINTAINER Travis Holton <travis@ideegeo.com>

RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

ENV KIBANA_VERSION 3.1.2
ENV LOGSTASH_VERSION 1.4.2

# Install Required Dependancies
RUN \
  apt-get -qq update && \
  apt-get -qy install wget --no-install-recommends && \
  wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main' \
    >> /etc/apt/sources.list && \
  echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' \
    >> /etc/apt/sources.list && \
  apt-get -qq update && \
  apt-get -qy install supervisor \
                      logstash \
                      nginx \
                      curl \
                      python-pip \
                      unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Kibana and Configure Nginx
ADD https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz /opt/
ADD http://download.elasticsearch.org/logstash/logstash/logstash-contrib-$LOGSTASH_VERSION.tar.gz /opt/
ADD kibana.conf /etc/nginx/sites-available/
RUN \
  mkdir -p /var/www && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  rm /etc/nginx/sites-enabled/default && \
  ln -s /etc/nginx/sites-available/kibana.conf \
    /etc/nginx/sites-enabled/kibana.conf && \
  cd /opt && tar xzf kibana-$KIBANA_VERSION.tar.gz && \
  cd /opt && tar xvzf  logstash-contrib-$LOGSTASH_VERSION.tar.gz -C logstash --strip-components=1 && \
  ln -s /opt/kibana-$KIBANA_VERSION /var/www/kibana && \
  sed -i 's/9200"/"+ window.location.port/g' /var/www/kibana/config.js && \
  sed -i 's/"http:/"https:/g' /var/www/kibana/config.js && \
  pip install elasticsearch-curator && \
  rm kibana-$KIBANA_VERSION.tar.gz

ADD supervisord.conf /etc/supervisor/conf.d/
ADD crons/ /etc/cron.hourly/

WORKDIR /usr/local/d8o/docker-elk
ADD patterns /usr/local/d8o/docker-elk/patterns

VOLUME ["/etc/logstash/conf.d"]
VOLUME ["/opt/kibana-3.1.2/app/dashboards"]
VOLUME ["/etc/nginx"]

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
