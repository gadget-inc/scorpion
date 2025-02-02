#!/usr/bin/env bash
# This script is run by the CD platform to deploy the app.
set -ex
export KUBECONFIG=${HOME}/.kube/config
export ENVIRONMENT=production
export CLUSTER="gke_superpro-production_us-central1-a_alpha"

GIT_SHA=$(git rev-parse HEAD)
export REVISION=${REVISION:-$GIT_SHA}

# deploy application to it's namespace
bundle exec krane render -f config/deploy/$ENVIRONMENT --current-sha=$REVISION | bundle exec krane deploy scorpion-production $CLUSTER --stdin --global-timeout 20m -f config/deploy/$ENVIRONMENT/secrets.ejson

if [ -n "$SENTRY_AUTH_TOKEN" ]; then
  sentry-cli releases new -p scorpion-backend -p scorpion-frontend $REVISION
  sentry-cli releases set-commits --auto $REVISION
  sentry-cli releases finalize "$REVISION"
else
  echo "Not sending release info to Sentry as SENTRY_AUTH_TOKEN is not set"
fi