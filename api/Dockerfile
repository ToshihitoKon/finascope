FROM ruby:3.4-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
