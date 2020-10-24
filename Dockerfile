ARG alpine_tag=latest

FROM alpine:${alpine_tag}

ARG monit_version

LABEL alpine.tag ${alpine_tag}
LABEL monit.id spritzerpyro-monit-docker
LABEL monit.version ${monit_version}
LABEL org.opencontainers.image.source https://github.com/SpritzerPyro/monit-docker

RUN addgroup -g 1000 monit && adduser -D -G monit -s /bin/bash -u 1000 monit

RUN for i in \
  /srv/bin \
  /srv/configs \
  /srv/log \
  /srv/run \
  /srv/tmp \
  /srv/var \
  ; do mkdir -p $i && chown -R 1000:1000 $i; done

RUN apk --no-cache add \
  bash \
  curl \
  docker \
  docker-compose \
  g++ \
  gcc \
  make \
  openssl-dev \
  tzdata \
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

COPY assets/entrypoint /usr/local/bin/entrypoint
COPY assets/healthcheck /usr/local/bin/healthcheck

COPY --chown=1000:1000 utils/* /srv/bin/

HEALTHCHECK \
  --interval=5s \
  --retries=3 \
  --start-period=10s \
  --timeout=20s \
  CMD [ "healthcheck" ]

ENTRYPOINT [ "entrypoint" ]

VOLUME [ "/srv/run" ]

USER monit

WORKDIR /home/monit

CMD ["monit", "-I"]
