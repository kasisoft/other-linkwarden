# Stage: monolith-builder
# Purpose: Uses the Rust image to build monolith
# Notes:
#  - Fine to leave extra here, as only the resulting binary is copied out
FROM docker.io/rust:1.80-bullseye AS monolith-builder

ARG BASE_PATH
ENV BASE_PATH=${BASE_PATH}

RUN set -eux && cargo install --locked monolith

# Stage: main-app
# Purpose: Compiles the frontend and
# Notes:
#  - Nothing extra should be left here.  All commands should cleanup
FROM node:18.18-bullseye-slim AS main-app

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir /data

WORKDIR /data

RUN echo "BASE_PATH=$BASE_PATH" >>.env_1

COPY ./package.json ./yarn.lock ./playwright.config.ts ./
RUN echo "BASE_PATH=$BASE_PATH" >>.env

RUN --mount=type=cache,sharing=locked,target=/usr/local/share/.cache/yarn \
    set -eux && \
    yarn install --network-timeout 10000000

RUN echo "BASE_PATH=$BASE_PATH" >>.env_2

# Copy the compiled monolith binary from the builder stage
COPY --from=monolith-builder /usr/local/cargo/bin/monolith /usr/local/bin/monolith

RUN echo "BASE_PATH=$BASE_PATH" >>.env_3

RUN set -eux && \
    npx playwright install --with-deps chromium && \
    apt-get clean && \
    yarn cache clean

COPY . .

RUN echo "BASE_PATH=$BASE_PATH" >>.env_4

RUN yarn prisma generate && \
    yarn build

EXPOSE 3000

CMD yarn prisma migrate deploy && yarn start
