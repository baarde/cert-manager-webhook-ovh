IMAGE_NAME := "baarde/cert-manager-webhook-ovh"
IMAGE_TAG := "latest"

OUT := $(shell pwd)/_out
TEST_ASSET_ETCD := $(OUT)/kubebuilder/bin/etcd
TEST_ASSET_KUBE_APISERVER := $(OUT)/kubebuilder/bin/kube-apiserver
TEST_ASSET_KUBECTL := $(OUT)/kubebuilder/bin/kubectl

$(shell mkdir -p "$(OUT)")

test:
	sh ./scripts/fetch-test-binaries.sh
	TEST_ASSET_ETCD="$(TEST_ASSET_ETCD)" TEST_ASSET_KUBE_APISERVER="$(TEST_ASSET_KUBE_APISERVER)" TEST_ASSET_KUBECTL="$(TEST_ASSET_KUBECTL)" \
	go test -v .

build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
	    --name cert-manager-webhook-ovh \
        --set image.repository=$(IMAGE_NAME) \
        --set image.tag=$(IMAGE_TAG) \
        deploy/cert-manager-webhook-ovh > "$(OUT)/rendered-manifest.yaml"
