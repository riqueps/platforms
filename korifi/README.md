## Install Korifi

### Create k3d cluster

`make create-k3d-cluster`

### Install Cert-manager

`make install-cert-manager`

### Install kpack

`make install-kpack`

### Install Countour Ingress

`make install-contour`

### Install Metrics Server

`make install-metrics-server`

### Install Service Bindings

`make install-service-bindings`

### Pre-Configuration

Create Korifi Namespaces

`make korifi-create-ns`

Setup Registry k8s Secret

```
export REGISTRY_USR=
export REGISTRY_PWD=
export REGISTRY_URL= 
```

`make setup-registry`

### Install Korifi

`make install-korifi`

Add bellow settings on contour configmap:

```
...
data:
  contour.yaml: |
    ...
    gateway:
      gatewayRef:
        name: contour
        namespace: korifi-gateway
    ...
```

Test it:

- cf api https://api.${BASE_DOMAIN} --skip-ssl-validation