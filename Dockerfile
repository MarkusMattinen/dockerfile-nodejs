# node.js, nginx, etcd registration and supervisord
FROM markusma/nginx-etcdregister:1.7

COPY config/etc/supervisor /etc/supervisor
COPY config/etc/confd /etc/confd
COPY config/etc/npmrc /etc/npmrc

RUN curl -sL https://deb.nodesource.com/setup | bash - \
 && apt-get update \
 && apt-get install -y --no-install-recommends nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
ENV PORT 5001
EXPOSE 5000

ONBUILD COPY . /app
ONBUILD RUN \
if [ -f /app/Aptfile ]; then \
      apt-get update \
   && apt-get install -y --no-install-recommends `cat /app/Aptfile` build-essential \
;fi \
 && npm install 2>&1 >/dev/null \
 && apt-get purge -y build-essential \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

