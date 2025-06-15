# Use latest Rust version to ensure compatibility
FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

# Create a dummy project to cache dependencies
WORKDIR /app
RUN USER=root cargo new --bin umami-alerts
WORKDIR /app/umami-alerts
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release

# Now build the actual application
RUN rm -rf src
RUN git clone https://github.com/Thunderbottom/umami-alerts.git .
# Ensure we're building with the correct dependencies
RUN touch src/main.rs
RUN cargo build --release

# Final runtime image
FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y openssl ca-certificates tzdata && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/umami-alerts/target/release/umami-alerts /usr/local/bin/
WORKDIR /config
ENTRYPOINT ["umami-alerts"]
CMD ["--config", "/config/config.toml"]
