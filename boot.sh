#!/bin/bash
sed s#\<env\>#$ES_PORT_9200_TCP_ADDR:9200# config/elasticsearch.yml.example > config/elasticsearch.yml
sed s#\<env\>#$DB_PORT_27017_TCP_ADDR:27017# config/mongoid.yml.example > config/mongoid.yml
bundle exec unicorn
