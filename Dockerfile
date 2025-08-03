ARG POSTGRESQL_MAJOR=17
ARG PGX_ULID_RELEASE=0.2.0
ARG TARGETARCH=amd64

FROM postgres:${POSTGRESQL_MAJOR}-bookworm AS base
ARG TARGETARCH
RUN case "${TARGETARCH}" in amd64|arm64) : ;; *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; esac

FROM alpine:3.20 AS downloader
ARG POSTGRESQL_MAJOR
ARG PGX_ULID_RELEASE
ARG TARGETARCH

ARG PGX_ULID_DEB="pgx_ulid-v${PGX_ULID_RELEASE}-pg${POSTGRESQL_MAJOR}-${TARGETARCH}-linux-gnu.deb"
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache curl ca-certificates file && \
    curl -fL \
      -o /tmp/${PGX_ULID_DEB} \
      "https://github.com/pksunkara/pgx_ulid/releases/download/v${PGX_ULID_RELEASE}/pgx_ulid-v${PGX_ULID_RELEASE}-pg${POSTGRESQL_MAJOR}-${TARGETARCH}-linux-gnu.deb"

FROM base AS production
ARG POSTGRESQL_MAJOR
ARG PGX_ULID_RELEASE
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.title="pg-ulid"
LABEL org.opencontainers.image.description="Personal build that ships pgx_ulid pre-built for PostgreSQL ${POSTGRESQL_MAJOR} so ULIDs are ready to use"
LABEL org.opencontainers.image.version="${PGX_ULID_RELEASE}"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY:-yehezkieldio/pg-ulid}"
LABEL org.opencontainers.image.licenses="MIT"
USER root
ARG PGX_ULID_DEB="pgx_ulid-v${PGX_ULID_RELEASE}-pg${POSTGRESQL_MAJOR}-${TARGETARCH}-linux-gnu.deb"
COPY --from=downloader /tmp/${PGX_ULID_DEB} /tmp/${PGX_ULID_DEB}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    if ! apt-get install -y --no-install-recommends /tmp/${PGX_ULID_DEB}; then \
      dpkg -i /tmp/${PGX_ULID_DEB} || apt-get -f install -y --no-install-recommends; \
    fi; \
    rm -rf /var/lib/apt/lists/* /tmp/${PGX_ULID_DEB}
USER postgres
ENV POSTGRESQL_MAJOR=${POSTGRESQL_MAJOR}

FROM production AS test
USER root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-17-pgtap && \
    rm -rf /var/lib/apt/lists/*
USER postgres