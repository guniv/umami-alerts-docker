FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/Thunderbottom/umami-alerts.git .
RUN cargo build --release

# Final runtime image
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y openssl ca-certificates tzdata cron && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/umami-alerts /usr/local/bin/
COPY scheduler.sh /scheduler.sh
RUN chmod +x /scheduler.sh

WORKDIR /config
ENTRYPOINT ["/scheduler.sh"]