# Derived from https://github.com/tcnksm/docker-sinatra
FROM phusion/baseimage:0.9.10

MAINTAINER asacalow "https://github.com/asacalow"

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

## Beginning of main build instructions

EXPOSE 8080
EXPOSE 80

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential wget git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev nginx libvips-dev libcurl4-openssl-dev memcached
RUN apt-get clean

RUN wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
RUN tar xvf ruby-2.1.2.tar.gz
RUN cd ruby-2.1.2; ./configure; make install
RUN gem update --system
RUN gem install bundler

ADD . /root/api
ENV RACK_ENV production
RUN cd /root/api && bundle install

RUN mkdir /etc/service/unicorn
ADD bin/unicorn.sh /etc/service/unicorn/run
RUN chmod ugo+x /etc/service/unicorn/run
RUN mkdir /etc/service/nginx
ADD bin/nginx.sh /etc/service/nginx/run
RUN chmod ugo+x /etc/service/nginx/run

ADD deploy/nginx.conf /etc/nginx/nginx.conf
ADD deploy/nginx.api.conf /etc/nginx/sites-enabled/api
RUN rm /etc/nginx/sites-enabled/default

VOLUME /root/api/public/assets/images
WORKDIR /root/api

## End of main build instructions

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
