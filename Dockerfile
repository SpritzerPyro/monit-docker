ARG alpine_tag=latest

FROM alpine:${alpine_tag}

ARG monit_version

RUN addgroup -g 1000 monit && adduser -D -G monit -u 1000 monit

RUN for i in \
  /srv/assets \
  /srv/bin \
  /srv/configs \
  /srv/log \
  /srv/run \
  /srv/var \
  ; do mkdir -p $i && chown -R 1000:1000 $i; done

RUN apk --no-cache add \
  curl \
  docker \
  docker-compose \
  g++ \
  gcc \
  make \
  openssl-dev \
  zlib-dev

RUN cd /srv/tmp && \
  curl https://mmonit.com/monit/dist/monit-${monit_version}.tar.gz | tar xz && \
  cd monit-${monit_version} && \
  ./configure --without-pam && \
  make && \
  make install && \
  rm -rf /srv/tmp/monit-${monit_version}

RUN addgroup monit docker && addgroup monit ping

EXPOSE 2812

COPY assets/healthcheck /usr/local/bin/healthcheck

HEALTHCHECK \
  --interval=5s \
  --retries=3 \
  --start-period=120s \
  --timeout=20s \
  CMD [ "healthcheck" ]

COPY --chown=1000:1000 assets/monitrc /home/monit/.monitrc

VOLUME [ "/srv/run" ]

USER monit

WORKDIR /srv/app

CMD ["monit", "-I"]
