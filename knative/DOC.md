helm install config-syncer \
  oci://ghcr.io/appscode-charts/config-syncer \
  --version v0.14.6 \
  --namespace kubeops --create-namespace \
  --set-file license=config-syncer-license-c16af861-40ad-4db3-9356-6d4867b29c6e.txt \
  --wait --burst-limit=10000 --debug

## Knative CRDs

- kservice
- king

## Knative Serving
  - HTTP based applications
  - Ease fo deployment and routing
  - Point in time deployment revisions
  - Autoscaling to and from zero containers

## Knative Eventing
  - Sources: Kafka, RabbitMQ, etc...
  - Channels and triggers
  - CloudEvents

## Kantive Functions
  - Built in runtimes
    - go, node.js, python, quarkus, rust
  - Language packs
    - customize tools
  - Build strategies
    - Local: s2i, buildpacks
    - Oncluster: buildpacks
  - Typically stateless
  - Invocations:
    - Imperative: typically http based
    - Reactive: typically event based

## VScode plugin
- Search for Knative