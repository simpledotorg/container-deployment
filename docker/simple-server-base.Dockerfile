# Base Phusion image with customizable Ruby support
FROM phusion/passenger-customizable:2.0.1

# Set ENV variables
ENV RUBY_VERSION=2.7.8
ENV BUNDLER_VERSION=2.4.22
ENV HOME /root

# Install only what's needed to build Ruby
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libgdbm-dev \
  autoconf \
  bison \
  libncurses5-dev \
  libffi-dev \
  libxml2-dev \
  libxslt1-dev \
  curl \
  wget \
  ca-certificates \
  gnupg2 \
  lsb-release \
  git

# Install Ruby 2.7.8 from source
WORKDIR /usr/src
RUN wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-${RUBY_VERSION}.tar.gz
RUN tar -xvzf ruby-${RUBY_VERSION}.tar.gz
WORKDIR /usr/src/ruby-${RUBY_VERSION}
RUN ./configure
RUN make -j"$(nproc)"
RUN make install
WORKDIR /usr/src
RUN rm -rf ruby-${RUBY_VERSION} ruby-${RUBY_VERSION}.tar.gz
RUN ln -sf /usr/local/bin/ruby /usr/bin/ruby
RUN ln -sf /usr/local/bin/gem /usr/bin/gem

# Verify Ruby and install Bundler
RUN gem install bundler -v ${BUNDLER_VERSION}

# THEN install app & system dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  redis-server \
  jq \
  cron \
  vim \
  s3cmd \
  libnss3-tools \
  firefox \
  kmod

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends yarn

# Install Node.js 16
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update
RUN apt-get install -y --no-install-recommends nodejs

# Install PostgreSQL client 14
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get install -y postgresql-client-14
RUN apt-get autoremove -y

# Download VPN client
WORKDIR /home/app
RUN wget https://in-simple-assets-public.s3.ap-south-1.amazonaws.com/linux_phat_client.tgz
RUN tar -xvf linux_phat_client.tgz
RUN rm -rf linux_phat_client.tgz

# Move logrotate to run hourly
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/

# Clean cache
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default workdir
WORKDIR /home/app

# Expose Passenger/Nginx default port
EXPOSE 3000

# Use baseimage-docker init system
CMD ["/sbin/my_init"]
