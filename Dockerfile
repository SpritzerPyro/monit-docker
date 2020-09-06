ARG ALPINE_TAG=latest

FROM alpine:${ALPINE_TAG}

ARG monit_version

RUN addgroup -g 1000 monit && adduser -D -G monit -h /srv/app -u 1000 monit

RUN for i in \
  /srv/app \
  /srv/log \
  /srv/monit \
  /srv/run \
  /srv/tmp \
  /srv/var \
  ; do mkdir -p $i && chown -R 1000:1000 $i; done

RUN apk --no-cache --update add curl g++ gcc make openssl-dev zlib-dev

RUN cd /srv/tmp && \
  curl https://mmonit.com/monit/dist/monit-${monit_version}.tar.gz | tar xz && \
  cd monit-${monit_version} && \
  ./configure --without-pam && \
  make && \
  make install && \
  rm -rf /srv/tmp/monit-${monit_version}

EXPOSE 2812

COPY healthcheck /usr/local/bin/healthcheck

HEALTHCHECK \
  --interval=5s \
  --retries=3 \
  --start-period=120s \
  --timeout=20s \
  CMD [ "healthcheck" ]

COPY --chown=1000:1000 monitrc /srv/app/.monitrc

VOLUME [ "/srv/run" ]

USER monit

WORKDIR /srv/app

CMD ["monit", "-I"]
