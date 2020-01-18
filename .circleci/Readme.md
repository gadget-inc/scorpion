# Scorpion CI Configuration

### CI environment setup

Some CI jobs use special dockerfiles to get to a usable test environment quickly.

For Ruby tests and Cypress integration tests, the `Dockerfile.circle` file in the root of the repo is used to construct this environment. To update the test environment, run these commands at the repo root:

```
docker build -t superpro/scorpion-test:latest -f Dockerfile.circle .
docker push superpro/scorpion-test:latest
```

For deploying to the kubernetes cluster, and the `superpro-inc/deploy-container` project is used. Update the deploy container contents there.
