#!/bin/bash

docker stop elasticsearch && docker rm elasticsearch

 docker run -h elasticsearch \
  --name elasticsearch -d \
  -p 9200:9200 \
  -p 9300:9300 \
  -v /data:/data \
  iwmn-es \
  /elasticsearch/bin/elasticsearch \
  -Des.config=/data/elasticsearch/elasticsearch.yml

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
