#!/usr/bin/env bash
# This script is run by the CD platform to deploy the app.
set -ex
export KUBECONFIG=${HOME}/.kube/config
export ENVIRONMENT=production
export CLUSTER="gke_superpro-production_us-central1-a_alpha"

GIT_SHA=$(git rev-parse HEAD)
export REVISION=${REVISION:-$GIT_SHA}

# deploy application to it's namespace
bundle exec krane render -f ./deploy/$ENVIRONMENT --current-sha=$REVISION | bundle exec krane deploy scorpion-production $CLUSTER --stdin -f ./deploy/$ENVIRONMENT/secrets.ejson