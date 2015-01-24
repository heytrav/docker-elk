#!/bin/bash

curator --host $ELASTICSEARCH_HOST delete --older-than $ES_CURATOR_DELETE_DAYS
