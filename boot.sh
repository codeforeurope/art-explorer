#!/bin/bash
sed s#\<env\>#$ES_PORT# config/elasticsearch.yml.example > config/elasticsearch.yml
sed s#\<env\>#$DB_PORT# config/mongoid.yml.example > config/mongoid.yml
bundle exec unicorn
