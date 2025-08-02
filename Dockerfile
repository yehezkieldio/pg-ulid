ARG POSTGRESQL_MAJOR=17
ARG PGX_ULID_RELEASE=0.2.0
ARG TARGETARCH=amd64

FROM postgres:${POSTGRESQL_MAJOR}-bookworm AS base
ARG POSTGRESQL_MAJOR
ARG PGX_ULID_RELEASE
ARG TARGETARCH
RUN case "${TARGETARCH}" in amd64|arm64) : ;; *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; esac

FROM alpine:3.20 AS downloader
ARG PGX_ULID_RELEASE
ARG POSTGRESQL_MAJOR
ARG TARGETARCH
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache curl ca-certificates && \
    curl -fSL -o /tmp/pgx_ulid.deb \
      "https://github.com/pksunkara/pgx_ulid/releases/download/v${PGX_ULID_RELEASE}/pgx_ulid-v${PGX_ULID_RELEASE}-pg${POSTGRESQL_MAJOR}-${TARGETARCH}-linux-gnu.deb"

FROM base AS production
ARG POSTGRESQL_MAJOR
ARG PGX_ULID_RELEASE
ENV DEBIAN_FRONTEND=noninteractive

USER root
COPY --from=downloader /tmp/pgx_ulid.deb /tmp/pgx_ulid.deb
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    if ! apt-get install -y --no-install-recommends /tmp/pgx_ulid.deb; then \
      dpkg -i /tmp/pgx_ulid.deb || apt-get -f install -y; \
    fi; \
    rm -rf /var/lib/apt/lists/* /tmp/pgx_ulid.deb

USER postgres
ENV POSTGRESQL_MAJOR=${POSTGRESQL_MAJOR}
