FROM ubuntu:16.04

# Set the locale
RUN apt-get update && apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Add ruby repo
RUN apt-get update && apt-get install -y software-properties-common build-essential zlib1g-dev nodejs wget libcurl3
RUN apt-add-repository ppa:brightbox/ruby-ng

# Install dependencies
RUN apt-get update && apt-get install -y nginx ruby2.2 ruby2.2-dev git
RUN gem install jekyll bundler
RUN chmod -R 777 /var/lib/gems

# Create a new user for the rest
RUN groupadd -r generator -g 1000 && \
    useradd -u 1000 -s /bin/bash -r -g generator generator

RUN mkdir /home/generator
RUN chown -R generator:generator /home/generator
RUN chmod -R 777 /usr/local/bin

# Copy in scripts to alter template and generate pages
COPY generate.sh /generate.sh
COPY inline-styles.css /inline-styles.css
RUN chmod +x generate.sh

# Copy in some other template files
RUN mkdir /templates
COPY footer.html /templates

VOLUME ["/content"]

# We will run the generator as a non-root user
USER generator

