FROM metabase/metabase:v0.65.2

ARG IMAGE_VERSION
ARG IMAGE_CREATED

LABEL org.opencontainers.image.source="https://github.com/compilerla/dashboards"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.created="${IMAGE_CREATED}"
LABEL org.opencontainers.image.url="ghcr.io/compilerla/dashboards/metabase"
LABEL org.opencontainers.image.documentation="https://docs.compiler.la/dashboards"

RUN apk update && apk add --no-cache socat

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
