SERVICE_IP := $(shell kubectl get svc --namespace default nginx-test --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")

.PHONY: e2e
e2e:
	GO111MODULE=on go get sigs.k8s.io/kind
	PATH=$(go env GOPATH)/bin:$(PATH) kind version
	PATH=$(go env GOPATH)/bin:$(PATH) kind create cluster
	kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
	helm install nginx-test nginx-test
	kubectl rollout status --timeout 2m -w deployments/nginx-test
	@echo "Frontend service loadbalancer ip: $(SERVICE_IP)"
	test 200 = $(shell curl -sL -w "%{http_code}\\n" http://${SERVICE_IP} -o /dev/null)
