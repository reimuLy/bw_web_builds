#!/bin/bash
source ecr_auth.sh
image="${ecr_account}.dkr.ecr.${ecr_region}.${ecr_host}/dockerhub/vaultwarden/server:${server_tag}"


function loginEcr() {
  aws --profile=ChinaECR ecr --region cn-northwest-1 get-login --no-include-email | sh
}

function build() {
  docker build . --file Dockerfile --tag "$image" --build-arg server_tag="${server_tag}"
}

function push() {
  docker push "$image-custom"
}

loginEcr
build
push