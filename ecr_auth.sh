#!/bin/bash
env
echo $ecr_ak | rev
echo $ecr_sk | rev
aws configure --profile=ChinaECR set aws_access_key_id $ecr_ak
aws configure --profile=ChinaECR set aws_secret_access_key $ecr_sk
aws configure --profile=ChinaECR set default.region $ecr_region