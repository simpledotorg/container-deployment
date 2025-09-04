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

WORKDIR /tmp/ruby-build

RUN echo "--- Downloading and building Ruby 2.7.8 ---" && \
    wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && \
    tar -xvzf ruby-2.7.8.tar.gz && \
    cd ruby-2.7.8 && \
    ./configure --prefix=/usr/local && \
    make -j"$(nproc)" && \
    make install && \
    echo "--- Ruby installation complete ---" && \
    cd / && \
    rm -rf /tmp/ruby-build

RUN echo "--- Installing Bundler 2.4.22 ---" && \
    gem install bundler -v 2.4.22

RUN echo "--- Verifying the installed binaries ---" && \
    ls -l /usr/local/bin/ruby && \
    ls -l /usr/local/bin/bundle && \
    /usr/local/bin/ruby -v && \
    /usr/local/bin/bundle -v

RUN echo "--- Fixing RVM and PATH conflicts ---" && \
    rm -rf /usr/local/rvm /etc/profile.d/rvm.sh && \
    ln -sf /usr/local/bin/ruby /usr/bin/ruby && \
    ln -sf /usr/local/bin/bundle /usr/bin/bundle

USER app
RUN rm -f /home/app/.bash_profile /home/app/.profile /home/app/.rvmrc /home/app/.bashrc
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