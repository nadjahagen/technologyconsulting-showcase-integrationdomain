#!/usr/bin/env bash
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
popd > /dev/null

docker build -t localhost:32773/cp-connect-emob:5.5.0 --build-arg CONNECTORS="confluentinc/kafka-connect-jdbc:5.5.0 debezium/debezium-connector-postgresql:1.3.1" -f $SCRIPT_DIR/Dockerfile.connect $SCRIPT_DIR
