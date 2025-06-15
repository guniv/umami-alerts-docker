FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/Thunderbottom/umami-alerts.git .
RUN cargo build --release

# Final runtime image with cron
FROM debian:bookworm-slim

# Install dependencies + cron
RUN apt-get update && \
    apt-get install -y openssl ca-certificates tzdata cron && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/umami-alerts /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /config

# Health check to verify cron is running
HEALTHCHECK --interval=5m --timeout=30s \
    CMD pgrep cron || exit 1

ENTRYPOINT ["/entrypoint.sh"]