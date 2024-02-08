export K3D_CLUSTER_NAME ?= k3d-cluster
export APP_NAME ?= test-app
export REG_URL ?= registry.domain.com

# Deploy Knative

deploy-knative: 
	$(MAKE) create-k3d-cluster 
	$(MAKE) install-cert-manager 
	$(MAKE) install-knative 
	$(MAKE) knative-selfsigned-cert 
	$(MAKE) test-knative-python

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

# Install Knative
install-knative:
	./scripts/makefile.sh install-knative

# Setup Selfsigned certificate
knative-selfsigned-cert:
	./scripts/makefile.sh knative-selfsigned-cert

# Test Conda app - Knative Serving
test-knative-python:
	cd $$(mktemp -d) && git clone --depth=1 https://github.com/paketo-buildpacks/samples && \
	cd samples/python/conda && pack build ${APP_NAME} --builder paketobuildpacks/builder:base
	docker tag ${APP_NAME} ${REG_URL}/${APP_NAME}:latest
	docker push ${REG_URL}/${APP_NAME}:latest

	kn service create ${APP_NAME} \
		--image ${REG_URL}/${APP_NAME}:latest \
		--port 8080 \
		--env TARGET=World \
		--force
	
	sleep 3 && curl -k https://${APP_NAME}.default.172.20.0.2.sslip.io
	@echo "****** test knative serving: succeeded"

# Delete K3d Cluster
delete-k3d-cluster:
	k3d cluster delete $(K3D_CLUSTER_NAME)