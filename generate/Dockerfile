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
RUN apt-get install -y libssl-dev libreadline-dev
RUN apt-get update && apt-get install -y nginx git

# Create a new user for the rest
RUN groupadd -r generator -g 1000 && \
    useradd -u 1000 -s /bin/bash -r -g generator generator

RUN mkdir /home/generator
RUN chown -R generator:generator /home/generator
RUN chmod -R 777 /usr/local/bin
#RUN chmod -R 777 /var/lib/gems

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

# Install rbenv to give us a non-root ruby environment
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby into our environment
RUN export PATH="/home/generator/.rbenv/bin:$PATH" && rbenv install 2.4.3 && rbenv global 2.4.3

# Install bundler and jekyll
RUN export PATH="/home/generator/.rbenv/bin:$PATH" \
    && eval "$(rbenv init -)" \
    && ruby --version \
    && gem install jekyll bundler

