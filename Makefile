# Project Setup
PROJECT_NAME := glasskube-gitops2
URL := https://github.com/thatmlopsguy/kind-gitops-glasskube

all: help

.PHONY: help
##@ General
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: \033[36m\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: kind-create-cluster kind-delete-cluster
##@ KinD
kind-create-cluster: ## Create kind cluster
	@if [ ! "$(shell kind get clusters | grep $(PROJECT_NAME))" ]; then \
		kind create cluster --name=$(PROJECT_NAME) --config kind/config.yaml --wait 180s; \
		kubectl wait pod --all -n kube-system --for condition=Ready --timeout 180s; \
	fi

kind-delete-cluster: ## Delete kind cluster
	@if [ "$(shell kind get clusters | grep $(PROJECT_NAME))" ]; then \
		kind delete cluster --name=$(PROJECT_NAME) || true; \
	fi

##@ Grasskube
grasskube-bootstrap: ## Grasskube bootstrap
	glasskube bootstrap git --url $(URL)

grasskube-serve: ## Grasskube serve
	glasskube serve

##@ Argo
argo-cd-ui: ## Access argocd ui
	@kubectl port-forward svc/argocd-server -n argocd 8088:443

argo-cd-password: ## Get argocd password
	@kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
