FROM fedora:43 AS builder
RUN dnf install -y gcc musl-gcc musl-libc-static protobuf-compiler && dnf clean all
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.94.0
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /build
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl -q \
    && cp target/x86_64-unknown-linux-musl/release/nativelink /nativelink

FROM scratch
COPY --from=builder /nativelink /nativelink
ENTRYPOINT ["/nativelink"]
