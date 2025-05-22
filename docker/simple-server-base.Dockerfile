# Ruby version 2.7.8
FROM phusion/passenger-customizable:2.0.1

# Install build dependencies for Ruby and app
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
      wget \
      curl \
      git \
      gnupg2 \
      redis-server \
      jq \
      cron \
      vim \
      s3cmd \
      libnss3-tools \
      firefox \
      kmod \
      libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Ruby 2.7.8 from source
WORKDIR /usr/src
RUN wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && \
    tar -xvzf ruby-2.7.8.tar.gz && \
    cd ruby-2.7.8 && \
    ./configure && make -j$(nproc) && make install && \
    cd .. && rm -rf ruby-2.7.8 ruby-2.7.8.tar.gz && \
    ln -sf /usr/local/bin/ruby /usr/bin/ruby && \
    ln -sf /usr/local/bin/gem /usr/bin/gem

# Install a compatible version of Bundler for Ruby 2.7.8
RUN gem install bundler -v 2.4.22

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends yarn

# Install Node.js 16
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get install -y --no-install-recommends nodejs

# Install Postgres client 14
RUN apt policy postgresql && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
  echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  apt update && apt install -y postgresql-client-14 && apt autoremove -y
# Install CPHC VPN Client
RUN apt-get install libnss3-tools firefox kmod wget -y

# Download CPHC VPN Client
WORKDIR /home/app
RUN wget https://in-simple-assets-public.s3.ap-south-1.amazonaws.com/linux_phat_client.tgz
RUN tar -xvf linux_phat_client.tgz && rm -rf linux_phat_client.tgz

# Move logrotate cron to hourly
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/
