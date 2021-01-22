#!/usr/bin/env bash
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
popd > /dev/null

docker build -t localhost:32773/cp-deploy-emob:5.5.0 --build-arg VERSION_CONFLUENT=5.5.0 -f $SCRIPT_DIR/Dockerfile.deploy $SCRIPT_DIR
