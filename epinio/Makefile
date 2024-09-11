# k3d
K3D_CLUSTER_NAME ?= k3d-cluster
# epinio
export EP_ADM_USR ?= epadm
export EP_ADM_PWD ?= password
export ADM_PWD_ENCRYPT := $(shell htpasswd -bnBC 10 "" ${EP_ADM_PWD} | tr -d :)
export EP_DEV_USR ?= orbitdev
export EP_DEV_PWD ?= password
export DEV_PWD_ENCRYPT := $(shell htpasswd -bnBC 10 "" ${EP_DEV_PWD} | tr -d :)
IP_ADDR := $(shell ifconfig -a | grep "inet " | awk 'NR==1{print $$2}')
export GLOBAL_DOMAIN ?= 127.0.0.1.sslip.io
export TLS_ISSUER ?= selfsigned-issuer

export CHART_NAME ?= 
export CHART_VERSION ?= 

install-epinio:
	@echo "Create k3d cluster..."
	-$(MAKE) create-cluster
	
	@echo "Deploy cert-manager into cluster..."
	-$(MAKE) install-cert-manager

	@echo "Deploy epinio into cluster..."
	$(MAKE) deploy-epinio

	@echo "Verify epinio installation..."
	$(MAKE) verify-epinio

	@echo "Deploy Kyverno"
	$(MAKE) deploy-kyverno

	@echo "Deploy ChartMuseum"
	$(MAKE) deploy-chartmuseum

	@echo "Deploy Code Server"
	$(MAKE) deploy-chartmuseum
	

# Create K3d Cluster
create-cluster:
	k3d cluster create $(K3D_CLUSTER_NAME) --k3s-arg "--disable=traefik@server:0" -p '443:443@loadbalancer'
	
	kubectl rollout status deployment metrics-server -n kube-system --timeout=480s
	
	# Install Traefik manually
	-helm repo add traefik https://helm.traefik.io/traefik && helm repo update
	helm install traefik -n traefik --create-namespace  traefik/traefik

# Cert-Manager
install-cert-manager:
	kubectl create namespace cert-manager
	-helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install cert-manager --namespace cert-manager jetstack/cert-manager \
		--set crds.enabled=true \
		--set extraArgs[0]=--enable-certificate-owner-ref=true

# Epinio
deploy-epinio:
	./makefile.sh deploy-epinio

# Verify Epinio
verify-epinio:
	@echo "\n\n****** Verify epinio admin ui/login works..."
	$(MAKE) test-epinio-ui-login
	@echo "\n\n****** Verify epinio install by push apps..."
	$(MAKE) test-epinio
	#@echo "\n\n****** Verify backing service by installing wordpress..."
	#$(MAKE) test-epinio-wordpress

test-epinio-ui-login:
	./makefile.sh test-epinio-ui-login

test-epinio-cli-login:
	epinio login -u $(EP_ADM_USR) -p $(EP_ADM_PWD) --trust-ca --skip-ssl-verification https://epinio.${GLOBAL_DOMAIN}

test-epinio:
	$(MAKE) test-epinio-cli-login
	$(MAKE) test-epinio-python
	echo "*** If you see this, your epinio stack is up and running !!! ***"

test-epinio-python:
	epinio target workspace
	cd $$(mktemp -d) && git clone --depth=1 https://github.com/paketo-buildpacks/samples && \
	cd samples/python/conda && epinio push --name conda-app --route conda-app.${GLOBAL_DOMAIN} 
	# sleep 3 && curl -k https://conda-app.${GLOBAL_DOMAIN}
	# @echo "****** test epinio app: succeeded"

# Delete K3d Cluster
delete-k3d-cluster:
	k3d cluster delete $(K3D_CLUSTER_NAME)

# Install pre-requisites
install-pre-requisites:
	./makefile.sh install-pre-requisites

# Install Kyverno

deploy-kyverno:
	-helm repo add kyverno https://kyverno.github.io/kyverno/
	helm repo update
	helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
		--set admissionController.replicas=1 \
		--set backgroundController.replicas=1 \
		--set cleanupController.replicas=1 \
		--set reportsController.replicas=1

	helm install kyverno-policies kyverno/kyverno-policies -n kyverno --create-namespace
	@echo '-----------------------'
	@echo 'Deploy kyverno policies'
	kubectl apply -f kyverno-policies/

ep-code-server:
	epinio push -n code-server1 --container-image-url codercom/code-server -e PASSWORD=${EP_ADM_PWD}

# ChartMuseum
deploy-chartmuseum:
	helm repo add chartmuseum https://chartmuseum.github.io/charts
	helm install chartmuseum -n chartmuseum --create-namespace chartmuseum/chartmuseum \
		--set ingress.enabled=true \
		--set ingress.hosts[0].name=chartmuseum.$(GLOBAL_DOMAIN) \
		--set ingress.hosts[0].path=/ \
		--set ingress.hosts[0].tls=true \
		--set ingress.hosts[0].tlsSecret=chartmuseum-tls \
		--set ingress.annotations.'cert-manager\.io/cluster-issuer=selfsigned-issuer' \
		--set env.open.DISABLE_API=false

undeploy-chartmuseum:
	helm uninstall chartmuseum -n chartmuseum 

# Helm package and push to chartmuseum
chart-package:
	helm package helm-charts/$(CHART_NAME)

chart-push:
	curl -k  --data-binary "@$(CHART_NAME)-$(CHART_VERSION).tgz" https://chartmuseum.$(GLOBAL_DOMAIN)/api/charts

chart-delete:
	curl -k -X DELETE https://chartmuseum.$(GLOBAL_DOMAIN)/api/charts/$(CHART_NAME)/$(CHART_VERSION)