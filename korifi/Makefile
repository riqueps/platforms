# K3d
export K3D_CLUSTER_NAME ?= korifi-cluster

# Koifi
export KORIFI_VERSION ?= 0.11.0
export ROOT_NAMESPACE ?= cf
export KORIFI_NAMESPACE ?= korifi
export ADMIN_USERNAME ?= cf-admin
export BASE_DOMAIN ?= korifi.127.0.0.1.sslip.io
export GATEWAY_CLASS_NAME ?= contour

# Registry
export REGISTRY_USR ?= ""
export REGISTRY_PWD ?= ""
export REGISTRY_URL ?= index.docker.io/riqueps


# Create K3D cluster
create-k3d-cluster:
	k3d cluster create $(K3D_CLUSTER_NAME) --k3s-arg "--disable=traefik@server:0" -p '443:443@loadbalancer'
	kubectl rollout status deployment metrics-server -n kube-system --timeout=480s

# Install Cert-manager
install-cert-manager:
	kubectl create namespace cert-manager
	-helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install cert-manager --namespace cert-manager jetstack/cert-manager \
		--set installCRDs=true \
		--set extraArgs[0]=--enable-certificate-owner-ref=true

# Install kpack
install-kpack:
	kubectl apply -f https://github.com/buildpacks-community/kpack/releases/download/v0.13.2/release-0.13.2.yaml

# Install countour ingress
install-contour:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install contour bitnami/contour --namespace projectcontour --create-namespace
	@echo ""
	@echo "...Installing Contour Gateway APIs from Standard Channel (CRDs)"
	@echo ""
	# kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.
	kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml
	./scripts/makefile.sh setup-contour-gw

# Install Metrics Server
install-metrics-server:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install Service bindings controller
install-service-bindings:

# Install Korifi
korifi-create-ns:
	./scripts/makefile.sh korifi-create-ns

setup-registry:
	kubectl --namespace "${ROOT_NAMESPACE}" create secret docker-registry image-registry-credentials \
    --docker-username="${REGISTRY_USR}" \
    --docker-password="${REGISTRY_PWD}" \
    --docker-server="${REGISTRY_URL}"

install-korifi:
	helm install korifi https://github.com/cloudfoundry/korifi/releases/download/v${KORIFI_VERSION}/korifi-${KORIFI_VERSION}.tgz \
    --namespace="${KORIFI_NAMESPACE}" \
    --set=generateIngressCertificates=true \
    --set=rootNamespace="${ROOT_NAMESPACE}" \
    --set=adminUserName="${ADMIN_USERNAME}" \
    --set=api.apiServer.url="api.${BASE_DOMAIN}" \
    --set=defaultAppDomainName="apps.${BASE_DOMAIN}" \
    --set=containerRepositoryPrefix=${REGISTRY_URL}/korifi/ \
    --set=kpackImageBuilder.builderRepository=${REGISTRY_URL}/kpack-builder \
    --set=networking.gatewayClass=${GATEWAY_CLASS_NAME} \
    --wait