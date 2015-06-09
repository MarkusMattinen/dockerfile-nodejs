# node.js, nginx, etcd registration and supervisord
FROM markusma/nginx-etcdregister:1.7

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.10.1

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
 && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
 && gpg --verify SHASUMS256.txt.asc \
 && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
 && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
 && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
 && npm install -g npm@"$NPM_VERSION" \
 && npm cache clear

COPY config/etc/supervisor /etc/supervisor
COPY config/etc/confd /etc/confd
COPY config/usr/local/etc/npmrc /usr/local/etc/npmrc

WORKDIR /app
ENV PORT 5001
EXPOSE 5000

ONBUILD COPY . /app
ONBUILD RUN \
if [ -f /app/Aptfile ]; then \
      apt-get update \
   && apt-get install -y --no-install-recommends `cat /app/Aptfile` build-essential \
;fi \
 && npm install >/dev/null \
 && apt-get purge -y build-essential \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

