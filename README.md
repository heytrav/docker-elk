# Logstash - Kibana

This repository provides some of the parts needed to set up a working Elasticsearch-Logstash-Kibana (ELK) system for our stack. It's still a *work in progress* so some steps may be subject to change.  Following is a rough outline of the steps needed to get the *ELK* setup working on your VM. It assumes that the relevant branches have been either checked out for `docker_vm`, `api`, `rabbitpy` or that the code has been merged.  I based this on Logstash's instructions for using `logstash-forwarder` and a Digital Ocean [tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04).


1. In the same directory where all your other repos are checked out:

     ```
     % mkdir -p data/{certs,private,elasticsearch}
     ```
3. In `~/data` run:

     ```
     % openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 \
         -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
     ```
2. Create `~/data/elasticsearch/elasticsearch.yml` with the following content:


     ```yaml
    path:
        logs: /data/log
        data: /data/data
        plugins: /data/elasticsearch/plugins
        work: /data/work
     ```
4. In `docker_vm` run `vagrant reload --provision` to make sure that `/data` gets mounted on the host.
5. Pull the latest `docker.domarino.com/iwmn-python3.4`
     ```
     docker pull docker.domarino.com/iwmn-python3.4
     ```
7. Build this container: `docker build -t docker-elk .`

8. Launch the container: `./launch.sh`

9. Launch any other repositories that are set up to forward to logstash. Currently these include:
  * `api` (merge pending)
  * `rabbitpy` (merge pending)




#Note
The docker container for this repo has been modified a bit from the [original](https://github.com/blacktop/docker-elk). Originally, this repo ran the entire ELK stack. Unfortunately the elasticsearch data was lost everytime the container was restarted.  Elasticsearch is provided by the [dockerfile/elasticsearch](https://registry.hub.docker.com/u/dockerfile/elasticsearch/) container at [docker.io](https://docker.io).
