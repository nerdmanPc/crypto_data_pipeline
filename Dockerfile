# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
ARG ALPINE_VERSION=3.23
ARG ELIXIR_VERSION=1.20
ARG APP_NAME=crypto_data_pipeline

FROM elixir:${ELIXIR_VERSION}-alpine AS builder

# Set build environment
ENV MIX_ENV=prod

# By convention, /opt is typically used for applications
WORKDIR /app

# Install build dependencies (add PostgreSQL build libs for Postgrex)
RUN apk add --no-cache build-base git postgresql-dev openssl-dev

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy configuration and dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy ecto migrations
COPY priv priv

# Copy source code and build the release
COPY config config
COPY lib lib
RUN mix compile
RUN mix release


# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION} AS runner

ARG APP_NAME=crypto_data_pipeline

# Install runtime dependencies (libstdc++ and ncurses are required by Erlang)
# Include postgresql-libs and libpq-related packages so the runtime can connect to Postgres/TimescaleDB
RUN apk add --no-cache libstdc++ openssl ncurses-libs tini postgresql-libs postgresql-client lksctp-tools

# Set runtime environment
ENV MIX_ENV=prod APP_NAME=${APP_NAME} LANG=C.UTF-8
WORKDIR /app

# Create a non-root user for security
RUN adduser -D ${APP_NAME}
USER ${APP_NAME}

# Copy the built release from the builder stage
# Replace 'my_app' with your actual Elixir application name
COPY --from=builder --chown=${APP_NAME}:${APP_NAME} /app/_build/prod/rel/${APP_NAME} ./

# Use tini to handle OS signals correctly
ENTRYPOINT ["/sbin/tini", "--"]

# Start the application
# bin/$APP_NAME eval MyApp.Release.migrate && 
CMD ["/bin/sh", "-lc", "/app/bin/$APP_NAME start"]
