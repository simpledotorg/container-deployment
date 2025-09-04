FROM phusion/passenger-customizable:2.0.1

RUN apt-get update && apt-get install -y --no-install-recommends \
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

WORKDIR /usr/src
RUN wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && \
    tar -xvzf ruby-2.7.8.tar.gz && \
    cd ruby-2.7.8 && \
    ./configure && make -j"$(nproc)" && make install && \
    cd .. && rm -rf ruby-2.7.8 ruby-2.7.8.tar.gz

RUN gem install bundler -v 2.4.22

RUN rm -f /etc/profile.d/rvm.sh

USER app
RUN rm -f /home/app/.bash_profile /home/app/.profile /home/app/.rvmrc
RUN echo 'export PATH=/usr/local/bin:$PATH' >> /home/app/.bashrc
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  redis-server \
  jq \
  cron \
  vim \
  s3cmd \
  libnss3-tools \
  firefox \
  kmod

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y --no-install-recommends yarn

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends nodejs

RUN apt policy postgresql && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
  echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && apt-get install -y postgresql-client-14 libpq-dev && apt-get autoremove -y

WORKDIR /home/app
RUN wget https://in-simple-assets-public.s3.ap-south-1.amazonaws.com/linux_phat_client.tgz && \
    tar -xvf linux_phat_client.tgz && \
    rm -rf linux_phat_client.tgz

RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]