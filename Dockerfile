# syntax=docker/dockerfile:1-labs
ARG WASMEDGE_VERSION=0.14.1

FROM rust:1.87.0-bookworm AS build

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        bash \
        binfmt-support \
        ca-certificates \
        curl \
        libclang-dev \
        pkg-config \
        zlib1g-dev \
      && rm -rf /var/lib/apt/lists/*

ARG WASMEDGE_VERSION

ENV WASMEDGE_DIR=/opt/wasmedge

ADD --checksum=sha256:cb2c7d286b0f979c7e4fed51d1595bc7feb69f2b98776d6941a8c6dd17a090c3 \
    --chmod=755 \
    https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh \
    /tmp/wasmedge_install_v2.sh
RUN set -eux; \
    /tmp/wasmedge_install_v2.sh --version=$WASMEDGE_VERSION --path=$WASMEDGE_DIR; \
    rm -f /tmp/wasmedge_install_v2.sh

WORKDIR /usr/src/moly

COPY . .

RUN --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=./target \
    set -eux; \
    cargo install \
      --locked \
      --profile=release \
      --path=./moly-server \
      --root=/usr/local; \
    strip \
      --strip-unneeded \
      --remove-section=.comment \
      --remove-section=.note \
      /usr/local/bin/moly-server

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
      && rm -rf /var/lib/apt/lists/*

RUN useradd -r -m -d /var/lib/moly moly

ENV WASMEDGE_DIR=/opt/wasmedge
COPY --from=build --parents $WASMEDGE_DIR/lib $WASMEDGE_DIR/plugin /
RUN echo "$WASMEDGE_DIR/lib" > /etc/ld.so.conf.d/wasmedge.conf \
      && ldconfig

COPY --from=build /usr/local/bin/moly-server /usr/local/bin/moly-server

USER moly
VOLUME ["/var/lib/moly"]

ENV RUST_LOG=debug

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD curl -f http://localhost:8765/ping || exit 1

EXPOSE 8765
CMD ["moly-server"]
