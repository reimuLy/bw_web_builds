#!/bin/bash
source ecr_auth.sh

image="${ecr_account}.dkr.ecr.${ecr_region}.${ecr_host}/dockerhub/vaultwarden/server:1.33.2-alpine-custom"


function loginEcr() {
  aws --profile=ChinaECR ecr --region cn-northwest-1 get-login --no-include-email | sh
}

function build() {
  docker build . --file Dockerfile --tag "$image"
}

function push() {
  docker push "$image"
}

loginEcr
build
push
