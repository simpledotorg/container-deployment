# Ruby version 2.7.4 with Passenger
FROM phusion/passenger-ruby27:2.0.1

# Install core dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    redis-server \
    jq \
    cron \
    vim \
    s3cmd && \
    apt-get autoremove -y && \
    apt-get autoclean -y

# -------------------
# Yarn installation
# -------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && \
    apt-key add /root/yarn-pubkey.gpg && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn

# -------------------
# Node.js (v16) installation
# -------------------
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs

# -------------------
# PostgreSQL Client 14 installation (using bullseye repo)
# -------------------
RUN apt policy postgresql && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-14 && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# -------------------
# Install VPN Client dependencies (with firefox fallback)
# -------------------
RUN apt-get update && \
    apt-get install -y libnss3-tools kmod wget && \
    apt-get install -y firefox || echo "⚠️ firefox not available via apt, skipping..."

# -------------------
# CPHC VPN Client Setup
# -------------------
WORKDIR /home/app
RUN wget https://in-simple-assets-public.s3.ap-south-1.amazonaws.com/linux_phat_client.tgz && \
    tar -xvf linux_phat_client.tgz && \
    rm -rf linux_phat_client.tgz

# -------------------
# Move logrotate cron job to hourly
# -------------------
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/
