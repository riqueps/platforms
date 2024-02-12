#!/bin/bash

set -e

function install-knative {
	echo '...Install knative serving'
	kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-crds.yaml
	
    echo '...Install knative serving-core'
	kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-core.yaml
	
    echo '...Install knative kourier network layer'
	kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.13.0/kourier.yaml
    
    echo '...Set knative to use Kourier'
    kubectl patch configmap/config-network \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

    KOURIER_IP=$(kubectl --namespace kourier-system get service kourier)

    echo '...Setting up DNS'
    kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-default-domain.yaml
    
    echo '...Install knative net-cert-manager-controller'
    kubectl apply -f https://github.com/knative/net-certmanager/releases/download/knative-v1.13.0/release.yaml
}

function knative-selfsigned-cert {
    echo '...Setting up knative config-certmanaer configmap'
    kubectl patch configmap config-certmanager -n knative-serving --type='merge' --patch-file patch-config-cert-manager.yaml
    
    echo '...Setting up knative config-network configmap'
    kubectl patch configmap config-network -n knative-serving  --type='merge' -p '{"data": {"external-domain-tls": "Enabled" , "http-protocol": "Redirected"}}'
}

function test-knative-func-python {
    cd $(mktemp -d) && git clone --depth=1 https://github.com/paketo-buildpacks/samples && cd samples/python/conda
    cat <<EOF >>func.yaml
specVersion: 0.36.0
name: ${APP_NAME}
runtime: python
created: $(date +"%Y-%m-%dT%H:%M:%S.%9NZ")
build:
  builder: pack
deploy:
  namespace: ${NAMESPACE}
  healthEndpoints:
    liveness: /
    readiness: /
EOF
    # Kn function deploy
    func deploy --registry ${REG_URL} --verbose
    # Testing
    #sleep 3 && curl -k https://${APP_NAME}.${NAMESPACE}.${DOMAIN}
	#@echo "****** test knative serving: succeeded"
}

$*