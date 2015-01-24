#!/bin/bash

curator --host $ELASTICSEARCH_HOST optimize --older-than $ES_CURATOR_OPTIMISE_DAYS
