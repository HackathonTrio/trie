# Build Stage
FROM --platform=linux/amd64 rustlang/rust:nightly as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang

## Add source code to the build stage.
ADD . /trie
WORKDIR /trie

## Build instructions
WORKDIR /trie/trie-db/fuzz
RUN cargo +nightly rustc --bin secio_crypto_decrypt_cipher -- \
    -C passes='sancov-module' \
    -C llvm-args='-sanitizer-coverage-level=3' \
    -C llvm-args='-sanitizer-coverage-inline-8bit-counters' \
    -Z sanitizer=address

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && apt-get install -y libssl-dev
COPY --from=builder trie/trie-db/fuzz/target/x86_64-unknown-linux-gnu/release/* /