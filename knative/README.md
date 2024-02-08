# Deploy Knative on a k3d cluster

`REG_URL=<registry-url> make deploy-knative`

# Step by step

## Install K3d Cluster

`make create-k3d-cluster`

## Install Cert-manager

`make install-cert-manager`

## Install Knative

`make install-knative`

## Setup SSLip on Knative

`make knative-selfsigned-cert`

## Test an App

### Deploy via Serving

For this activity you need to have a Registry with a valid certificate.

`REG_URL=<registry-url> make test-knative-python`

List your service:

  `kn service list`