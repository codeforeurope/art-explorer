#!/bin/bash
sed s/\<env\>/$ES_PORT/ config/elasticsearch.yml.example > config/elasticsearch.yml
bundle exec unicorn
