FOO := $(shell ls)
NODE_PORT = $(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services nginx-test)
NODE_IP = $(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")

.PHONY: bootstrap
bootstrap:
	GO111MODULE=on go get sigs.k8s.io/kind
	PATH=$(go env GOPATH)/bin:$(PATH) kind create cluster

.PHONY: e2e
e2e: $(NODE_PORT) $(NODE_IP)
	PATH=$(go env GOPATH)/bin:$(PATH) kind version
	kubectl apply -f nginx-test.yaml
	kubectl rollout status --timeout 2m -w deployments/nginx-test
	# kubectl get services -o wide
	# kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services nginx-test
	# URL = $(value NODE_IP):$(value NODE_PORT)
	# @echo $(URL)
	# kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services nginx-test
	@echo "Frontend service loadbalancer ip: $(value NODE_IP):$(value NODE_PORT)"
	test 200 = $$(curl -sL -w "%{http_code}\\n" http://$(value NODE_IP):$(value NODE_PORT) -o /dev/null)

.PHONY: test
test: $(FOO)
	echo $(value FOO)
	echo $(FOO)
	echo 'done'
