#!/bin/bash
source ecr_auth.sh

image="${ecr_account}.dkr.ecr.${ecr_region}.${ecr_host}/web-vault:${tag}"


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