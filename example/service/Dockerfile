FROM alpine:3.12.1

COPY healthcheck /usr/local/bin/healthcheck

HEALTHCHECK \
  --interval=5s \
  --retries=2 \
  --timeout=5s \
  CMD [ "healthcheck" ]

CMD [ "tail", "-f", "/dev/null" ]
