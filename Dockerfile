FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/Thunderbottom/umami-alerts.git .
RUN cargo build --release

# Final runtime image with cron and logging
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y openssl ca-certificates tzdata cron rsyslog && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/umami-alerts /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Configure logging
RUN touch /var/log/cron.log && \
    sed -i '/#cron.*/c\cron.* /proc/1/fd/1' /etc/rsyslog.conf && \
    sed -i 's/^#module(load="imklog")/module(load="imklog")/' /etc/rsyslog.conf

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]