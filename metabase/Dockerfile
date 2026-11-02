FROM metabase/metabase:v0.65.2

RUN apk add --no-cache socat

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
