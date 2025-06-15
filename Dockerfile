FROM rust:1.80-slim-bullseye AS builder

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/Thunderbottom/umami-alerts.git .
RUN cargo build --release

FROM debian:bullseye-slim
RUN apt-get update && \
    apt-get install -y openssl ca-certificates tzdata && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/umami-alerts /usr/local/bin/
WORKDIR /config
ENTRYPOINT ["umami-alerts"]
CMD ["--config", "/config/config.toml"]
