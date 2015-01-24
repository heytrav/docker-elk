#!/bin/bash

: ${IWMN_ENV:=development}
# Have elasticsearch curator run with relatively small optimise and delete
# thresholds by default to keep the ES indices on our VMs from becoming too
# large. Should be set to something larger on production systems.
: ${ELASTICSEARCH_HOST:=elasticsearch}
: ${ES_CURATOR_OPTIMISE_DAYS:=7}
: ${ES_CURATOR_DELETE_DAYS:=14}


usage() { echo "Usage: $0 [-i]" 1>&2; exit 1; }
OPTIND=1
INTERACTIVE_ARGS="-d"
INTERACTIVE=0
CMD=
while getopts "iec:h" opt; do
    case "$opt" in
        e)
            ELASTICSEARCH=1
            ;;
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

if [ $ELASTICSEARCH ]; then
    docker stop elasticsearch && docker rm elasticsearch

    docker run -h elasticsearch -d \
    --name elasticsearch  \
    -p 9200:9200 \
    -p 9300:9300 \
    --volumes-from elasticsearch-data \
    dockerfile/elasticsearch \
    /elasticsearch/bin/elasticsearch -Des.config=/usr/local/d8o/elasticsearch/elasticsearch.json

fi

docker stop docker-elk && docker rm docker-elk

docker run $INTERACTIVE_ARGS  \
    -p 9090:443 \
    -p 5004:5004 \
    -p 25826:25826 \
    --link elasticsearch:elasticsearch \
    --name docker-elk \
    -h docker-elk \
    -v /usr/local/d8o/docker-elk/logstash:/etc/logstash/conf.d:r \
    --volumes-from logstash-data \
    -e ELASTICSEARCH_HOST=$ELASTICSEARCH_HOST \
    -e ES_CURATOR_DELETE_DAYS=$ES_CURATOR_DELETE_DAYS \
    -e ES_CURATOR_OPTIMISE_DAYS=$ES_CURATOR_OPTIMISE_DAYS \
    -e IWMN_ENV=$IWMN_ENV \
    docker-elk $CMD
