## Local Epinio Installation

### Pre-Requisites
- Docker
- K3D
- Epinio CLI
- Kubctl
- Helm

`make install-pre-requistes`

## Components

- K3D: Local k8s cluster
- Cert-Manager: Certificate manager for k8s environment
- Epinio: Plataform Orchestrator
- Kyverno: Policy management for k8s environament
- Chart Musuem: Chart repository

### Deploy Platform

**Important:** be sure you're not connected to any other k8s cluster

`make install-epinio`

### Package and push helm-charts

*Charts name and folder cannot contain dash (-)*

Export your envs:
```
export CHART_NAME ?= <chart folder name>
export CHART_VERSION ?= <chart version>
```

Package chart:

`make chart-package`

Push to Chartmuseum:

`make chart-push`

Delete from Chartmuseum`

`make chart-delete`

### Deploy code-server as a remote devevlopment environment

`make code-server`
