# syntax=docker/dockerfile:1

# Compile the web vault using docker
# Usage:
#    Quick and easy:
#    `make container-extract`
#    or, if you just want to build
#    `make container`
#    The default is to use `docker` you can also configure `podman` via a `.env` file
#    See the `.env.template` file for more details
#
#    docker build -t web_vault_build .
#    docker create --name bw_web_vault_extract web_vault_build
#    docker cp bw_web_vault_extract:/bw_web_vault.tar.gz .
#    docker rm bw_web_vault_extract
#
#    Note: you can use --build-arg to specify the version to build:
#    docker build -t web_vault_build --build-arg VAULT_VERSION=main .
FROM node:20-bookworm AS build
RUN node --version && npm --version

# Can be a tag, release, but prefer a commit hash because it's not changeable
# https://github.com/bitwarden/clients/commit/${VAULT_VERSION}
#
# Using https://github.com/bitwarden/clients/releases/tag/web-v2024.6.2
ARG VAULT_VERSION=e2354e8694ab5e532d04f275e4bd6bf560c7509b
ENV VAULT_VERSION=$VAULT_VERSION
ENV VAULT_FOLDER=bw_clients
ENV CHECKOUT_TAGS=false

RUN mkdir /bw_web_builds
WORKDIR /bw_web_builds

COPY patches ./patches
COPY resources ./resources
COPY scripts ./scripts

RUN ./scripts/checkout_web_vault.sh
RUN ./scripts/patch_web_vault.sh
RUN ./scripts/build_web_vault.sh
RUN mv "${VAULT_FOLDER}/apps/web/build" ./web-vault

RUN tar -czvf "bw_web_vault.tar.gz" web-vault --owner=0 --group=0
# Output the sha256sum here so people are able to match the sha256sum from the CI with the assets and the downloaded version if needed
RUN echo "sha256sum: $(sha256sum "bw_web_vault.tar.gz")"

# We copy the final result as a separate empty image so there's no need to download all the intermediate steps
# The result is included both uncompressed and as a tar.gz, to be able to use it in the docker images and the github releases directly
ARG server_tag
FROM vaultwarden/server:${server_tag}
RUN mv /web-vault /web-vault-backup
# hadolint ignore=DL3010
COPY --from=build /bw_web_builds/bw_web_vault.tar.gz /bw_web_vault.tar.gz
COPY --from=build /bw_web_builds/web-vault /web-vault