NAMESPACE := kube-system
RELEASE := sealed-secrets
CHART := sealed-secrets/sealed-secrets
REPO := https://bitnami-labs.github.io/sealed-secrets
VERSION := 2.15.3
FULLNAME := sealed-secrets-controller

.PHONY: repo
repo:
	helm repo add sealed-secrets $(REPO)
	helm repo update

.PHONY: install
install: repo
	helm install $(RELEASE) $(CHART) \
	  --namespace $(NAMESPACE) \
	  --create-namespace \
	  --version $(VERSION) \
	  --set fullnameOverride=$(FULLNAME)

.PHONY: upgrade
upgrade: repo
	helm upgrade $(RELEASE) $(CHART) \
	  --namespace $(NAMESPACE) \
	  --version $(VERSION) \
	  --set fullnameOverride=$(FULLNAME)

.PHONY: uninstall
uninstall:
	helm uninstall $(RELEASE) -n $(NAMESPACE)

.PHONY: status
status:
	helm status $(RELEASE) -n $(NAMESPACE)
