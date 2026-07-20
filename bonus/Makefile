ARGO_PORT ?= 8080
APP_PORT ?= 8888

all: install build

build:
	@./scripts/build.sh

install:
	@sudo ./scripts/install.sh

argo-port:
	@kubectl port-forward svc/argocd-server -n argocd $(ARGO_PORT):443

gitlab-port:
	@kubectl port-forward svc/gitlab-webservice-default -n gitlab 8081:8181

app-port:
	@kubectl port-forward svc/argo-app-service -n dev $(APP_PORT):8080

fclean:
	@k3d cluster delete argo-cluster || true

show:
	@kubectl get nodes

gitlab-passwd:
	@kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode; echo

argocd-passwd:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

show-argocd:
	@kubectl get pods -n argocd
	@kubectl get svc -n argocd
	@kubectl get deployments -n argocd

show-dev:
	@kubectl get pods -n dev
	@kubectl get svc -n dev
	@kubectl get deployments -n dev

show-gitlab:
	@kubectl get pods -n gitlab
	@kubectl get svc -n gitlab
	@kubectl get deployments -n gitlab

re: fclean all
