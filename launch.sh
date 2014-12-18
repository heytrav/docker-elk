#!/bin/bash


docker stop docker-elk && docker rm docker-elk
#docker run -i -t  \
docker run -d  \
    -p 9090:443 \
    -p 5004:5004 \
    --link elasticsearch:elasticsearch \
    --name docker-elk \
    -h docker-elk \
    -v /usr/local/d8o/docker-elk/logstash:/etc/logstash/conf.d:r \
    -v /data:/usr/local/d8o/data \
    docker-elk
    #docker-elk /bin/bash
