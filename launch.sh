#!/bin/bash


docker stop docker-elk && docker rm docker-elk
docker run -d  \
    -v /usr/local/d8o/docker-elk/logstash:/etc/logstash/conf.d \
    -v /usr/local/d8o/docker-elk/dashboards:/etc/kibana-3.1.2/app/dashboards \
    -p 8080:80 \
    -p 5004:5004 \
    --name docker-elk \
    -h docker-elk \
    -v /data:/usr/local/d8o/data \
    docker-elk
