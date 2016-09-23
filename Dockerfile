FROM ubuntu:16.04
RUN ls
# Add ruby repo
RUN apt-get update
RUN apt-get install -y software-properties-common build-essential
RUN apt-add-repository ppa:brightbox/ruby-ng

# Install dependencies
RUN apt-get update
RUN apt-get install -y nginx ruby2.2 ruby2.2-dev git
RUN gem install bundler
RUN gem install i18n -v '0.7.0'
RUN gem install json -v '1.8.3'

# Create a new user for the rest
RUN useradd generator -s /bin/bash
RUN mkdir /home/generator
RUN chown generator:generator /home/generator

USER generator

# Install the content and required bundles:
RUN git clone https://github.com/nhsconnect/gpconnect.git ~/gpconnect

USER root
#RUN gem install json -v '1.8.3'

USER generator
RUN cd ~/gpconnect && bundle install

# Overwrite the templates used to incorporate the developer network elements
# TODO

# Generate the pages
RUN cd ~/gpconnect && bundle exec jekyll build --destination /outputhtml

