#!/bin/bash
source ecr_auth.sh
image="${ecr_account}.dkr.ecr.${ecr_region}.${ecr_host}/dockerhub/vaultwarden/server:${server_tag}"


function loginEcr() {
  aws --profile=ChinaECR ecr --region cn-northwest-1 get-login --no-include-email | sh
}

function build() {
  docker build --file Dockerfile --build-arg SERVER_TAG=${server_tag} --tag "$image" .
}

function push() {
  docker push "$image-custom"
}

loginEcr && build && push