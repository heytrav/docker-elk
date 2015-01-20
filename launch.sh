#!/bin/bash

usage() { echo "Usage: $0 [-i]" 1>&2; exit 1; }
OPTIND=1
INTERACTIVE_ARGS="-d"
INTERACTIVE=0
CMD=
while getopts "ic:h" opt; do
    case "$opt" in
        c)
            CMD=$OPTARG
            ;;
        i)
            INTERACTIVE=1
            INTERACTIVE_ARGS="-i -t"
            ;;
        h)
            usage
            ;;
    esac
done

docker stop elasticsearch && docker rm elasticsearch

 docker run -h elasticsearch -d \
  --name elasticsearch  \
  -p 9200:9200 \
  -p 9300:9300 \
  -v /data:/data \
  dockerfile/elasticsearch \
  /elasticsearch/bin/elasticsearch  -Des.config=/data/elasticsearch/elasticsearch.yml

docker stop docker-elk && docker rm docker-elk

docker run $INTERACTIVE_ARGS  \
    -p 9090:443 \
    -p 5004:5004 \
    -p 25826:25826 \
    --link elasticsearch:elasticsearch \
    --name docker-elk \
    -h docker-elk \
    -v /usr/local/d8o/docker-elk/logstash:/etc/logstash/conf.d:r \
    -v /data:/usr/local/d8o/data \
    docker-elk $CMD
