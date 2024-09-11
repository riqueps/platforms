#!/bin/bash

set -e

function deploy-epinio {
	helm repo add epinio https://epinio.github.io/helm-charts && helm repo update
	kubectl rollout status deployment traefik -n traefik --timeout=480s

	helm uninstall -n epinio epinio && sleep 15

	helm install epinio -n epinio --create-namespace epinio/epinio \
		--set global.domain=${GLOBAL_DOMAIN} \
		--set global.tlsIssuer=${TLS_ISSUER} \
		--set api.users[0].roles[0]=admin \
		--set api.users[0].username=${EP_ADM_USR} \
		--set api.users[0].passwordBcrypt="$(echo ${ADM_PWD_ENCRYPT})" \
		--set api.users[1].roles[0]=user \
		--set api.users[1].username=${EP_DEV_USR} \
		--set api.users[1].passwordBcrypt="$(echo ${DEV_PWD_ENCRYPT})"

	# Patch Kubed with a rancher mirroed image
    kubectl patch pod  -n epinio \
		$(kubectl get pods -n epinio -l 'app.kubernetes.io/name=kubed' --no-headers -o custom-columns=":metadata.name") \
		-p '{"spec": {"containers": [{"name": "kubed", "image": "rancher/mirrored-appscode-kubed:v0.13.2"}]}}'

	kubectl rollout status deployment epinio-server -n epinio --timeout=480s
	kubectl wait --for=condition=ready certificate epinio -n epinio --timeout=480s

	# Create custom services on service catalog
	kubectl apply -f code-server.yaml
}

function test-epinio-ui-login {
	curl -s -k "https://epinio.${GLOBAL_DOMAIN}"
	curl -s -k "https://epinio.${GLOBAL_DOMAIN}/pp/v1/epinio/rancher/v3-public/authProviders/local/login" -X POST  \
		-d @- <<EOF
{"description":"UI session","responseType":"cookie","username":"${EP_ADM_USR}","password":"${ORBITADM_PWD}"}
EOF

	curl -s -k "https://epinio.${GLOBAL_DOMAIN}/pp/v1/epinio/rancher/v3-public/authProviders/local/login" -X POST  \
		-d @- <<EOF
{"description":"UI session","responseType":"cookie","username":"${EP_DEV_USR}","password":"${ORBITDEV_PWD}"}
EOF
}


$*