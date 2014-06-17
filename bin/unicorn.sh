#!/bin/bash
# cd /root/api && bundle exec rerun -b 'unicorn'
cd /root/api && bundle exec unicorn -D -c /root/api/unicorn.conf
