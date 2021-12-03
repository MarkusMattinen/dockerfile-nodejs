FROM markusma/nginx-etcdregister:1.20-ubuntu-bionic-s6

RUN curl -sSL https://deb.nodesource.com/setup_12.x | bash - \
 && apt-get install -y nodejs

COPY etc/ /etc/

WORKDIR /app
ENV PORT=5000 APP_PORT=5001 NODE_ENV=production
EXPOSE 5000

ONBUILD COPY Aptfile* /app/
ONBUILD RUN \
    if [ -f /app/Aptfile.sources.list ]; then \
      APT_OPTIONS="$APT_OPTIONS -o dir::etc::sourcelist=/app/Aptfile.sources.list" \
    ;fi \
 && if [ -f /app/Aptfile.pubkeys ]; then \
      APT_KEYRING_FILE="/app/apt-trusted.gpg" \
   && cp /etc/apt/trusted.gpg "$APT_KEYRING_FILE" 2>/dev/null || true \
   && APT_OPTIONS="$APT_OPTIONS -o dir::etc::trusted=$APT_KEYRING_FILE" \
   && cat /app/Aptfile.pubkeys | while read KEYSERVER KEYID; do \
        apt-key --keyring "$APT_KEYRING_FILE" adv --keyserver $KEYSERVER --recv-keys $KEYID \
      ;done \
    ;fi \
 && if [ -f /app/Aptfile ]; then \
      apt-get $APT_OPTIONS update \
   && apt-get $APT_OPTIONS install -y --no-install-recommends `cat /app/Aptfile` \
   && apt-get autoremove -y \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* $HOME/.cache \
    ;fi

ONBUILD COPY package*.json /app/
ONBUILD RUN \
apt-get update \
 && apt-get install -y --no-install-recommends build-essential libtool autotools-dev automake git \
 && npm install >/dev/null \
 && apt-get purge -y build-essential libtool autotools-dev automake git \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* $HOME/.cache
ONBUILD COPY . /app

