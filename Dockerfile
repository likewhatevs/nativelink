FROM rust:1.94-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
        musl-tools \
        protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /build
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl -q \
    && cp target/x86_64-unknown-linux-musl/release/nativelink /nativelink

FROM scratch
COPY --from=builder /nativelink /nativelink
ENTRYPOINT ["/nativelink"]
