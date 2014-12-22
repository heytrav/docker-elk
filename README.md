# Logstash - Kibana 

This repository provides *some* of the parts needed to set up a working Elasticsearch-Logstash-Kibana (ELK) system for our stack. It's still a *work in progress* so some steps may be subject to change. The docker container for this repo has been modified from the [original](https://github.com/blacktop/docker-elk). It provides the Logstash and Kibana bits. Elasticsearch is provided by the [dockerfile/elasticsearch](https://registry.hub.docker.com/u/dockerfile/elasticsearch/) container at [docker.io](https://docker.io).

Following is a rough outline of the steps needed to get the *ELK* setup working on your VM. It assumes that the relevant branches have been either checked out for `docker_vm`, `api`, `rabbitpy` or that the code has been merged.

1. In the same directory where all your other repos are checked out:

     ```
     % mkdir -p data/{certs,private,elasticsearch}
     ```
2. Create `~/data/elasticsearch/elasticsearch.yml` with the following content:


     ```yaml
     path:
         logs: /data/log
         data: /data/data
     ```
3. In `~/data` run: 

     ```
     % openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 \
         -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
     ```
4. In `docker_vm` run `vagrant reload --provision` to make sure that `/data` gets mounted on the host.
5. Build or pull the latest `docker.domarino.com/iwmn-python3.4`
  * `docker build -t docker.domarino.com/iwmn-python3.4 containers/python3.4`
  * or `docker pull docker.domarino.com/iwmn-python3.4`
6. Pull and run `dockerfile/elasticsearch`
     ```
     docker run -h elasticsearch \
      --name elasticsearch -d \
      -p 9200:9200 \
      -p 9300:9300 \
      -v /data:/data \
      dockerfile/elasticsearch \
      /elasticsearch/bin/elasticsearch \
      -Des.config=/data/elasticsearch/elasticsearch.yml
     ```
This should start a container with the elastic server running and listening for logs to be fed into it. It will write this data into `~/data/data` and `~/data/logs`.

7. Build this container: `docker build -t docker-elk .`

8. Launch the container: `./launch.sh`

9. Launch any other repositories that are set up to forward to logstash. Currently these include:
  * `api` (merge pending)
  * `rabbitpy` (merge pending)
