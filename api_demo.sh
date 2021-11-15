#!/usr/bin/env bash
set -euo pipefail

# boilderplate nomad job
#
#            ┌── removes all the comments
nomad init --short

# command for generating valid JSON version of HCL jobs
nomad job run -output example.nomad >example.json

# create job
curl -XPUT -d @example.json "http://127.0.0.1:4646/v1/job/example" | jq

# get job
curl "http://localhost:4646/v1/job/example" | jq

# get job allocations
curl "http://localhost:4646/v1/job/example/allocations" | jq

# get allocation ID
alloc_id=$(curl "http://localhost:4646/v1/job/example/allocations" | jq -r '.[0].ID')

# get allocation logs
curl "http://localhost:4646/v1/client/fs/logs/${alloc_id}?task=redis&type=stdout" | jq -r '.Data' | base64 -d

# get job deployments
curl "http://localhost:4646/v1/job/example/deployments" | jq

# get latest job deployment
curl "http://localhost:4646/v1/job/example/deployment" | jq

# delete job
curl --request DELETE "http://localhost:4646/v1/job/example?purge=true" | jq
