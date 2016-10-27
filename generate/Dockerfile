FROM ubuntu:16.04

# Add ruby repo
RUN apt-get update && apt-get install -y software-properties-common build-essential zlib1g-dev nodejs wget
RUN apt-add-repository ppa:brightbox/ruby-ng

# Install dependencies
RUN apt-get update && apt-get install -y nginx ruby2.2 ruby2.2-dev git
RUN gem install jekyll bundler
RUN chmod -R 777 /var/lib/gems

# Create a new user for the rest
RUN useradd generator -s /bin/bash
RUN mkdir /home/generator
RUN chown -R generator:generator /home/generator
RUN chmod -R 777 /usr/local/bin

# Copy in scripts to alter template and generate pages
COPY generate.sh /generate.sh
RUN chmod +x generate.sh

# Copy in some other template files
RUN mkdir /templates
COPY footer.html /templates

# We will run the generator as a non-root user
USER generator

