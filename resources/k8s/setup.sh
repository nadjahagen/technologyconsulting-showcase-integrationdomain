#!/usr/bin/env bash
#bash script for installation of all platform components with helm charts
#make sure to execute beforehand:
#     $ minikube start
#     $ minikube addons enable registry

function deploy_all () {
    buildConnectImage
    buildDeployImage
    install_all
}

function install_all () {
    #install components with defined values.yaml file
    helm install -f ./deployments/grafana/grafana.values.yaml grafana ./charts/grafana
    helm install -f ./deployments/hivemq-operator/hivemq.values.yaml hivemq ./charts/hivemq-operator
    helm install -f ./deployments/mongodb/mongodb.values.yaml mongodb ./charts/mongodb
    helm install -f ./deployments/postgresql/postgres.values.yaml postgres ./charts/postgresql

    #install all Confluent components with the values.yaml files defined in ./deployments/confluent-platform
    helm install confluent-platform ./charts/confluent-platform $(for file in ./deployments/confluent-platform/*.yaml; do echo "--values $file"; done)

    #TO DO: healthcheck for Confluent components and especially Kafka Connect
    #install deployment of connector configurations
    #helm install connector-deploy ./deployments/deploy/connector-deploy
}

function buildConnectImage () {
    #build the custom Kafka Connect image
    . ./deployments/confluent-platform/build-connect-image.sh
    #push to docker registry
    docker push localhost:32773/cp-connect-emob:5.5.0
}

function buildDeployImage () {
    #build image to deploy the connector configurations to Kafka Connect
    . ./deployments/deploy/build-deploy-image.sh
    #push to docker registry
    docker push localhost:32773/cp-deploy-emob:5.5.0
}

function down_all () {
    log "INFO" "Uninstalling all deployments."
    helm uninstall confluent-platform
    helm uninstall mongodb
    helm uninstall postgres
    helm uninstall grafana
    helm uninstall hivemq
    helm uninstall connector-deploy
}

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse flags
while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp $MODE
    exit 0
    ;;
  esac
  shift
done

# Determine mode of operation
if [ "$MODE" == "up" ]; then
  log "Deploying all components: Confluent-Platform, HiveMQ, Grafana, MongoDB, PostgreSQL"
  deploy_all
elif [ "$MODE" == "down" ]; then
  log "Uninstalling all components."
  down_all
else
  printHelp
  exit 1
fi
