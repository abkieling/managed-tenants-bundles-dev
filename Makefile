COS_FLEETSHARD_SYNC_VERSION = 1.0.3
COS_FLEETSHARD_OPERATOR_CAMEL_VERSION = 1.0.3
COS_FLEETSHARD_OPERATOR_DEBEZIUM_VERSION = 1.0.3
CAMEL_K_OPERATOR_VERSION = 1.9.0-dab66604
STRIMZI_OPERATOR_VERSION = 0.28.0-1
IMAGE_BASE = quay.io/abrianik
COS_FLEETSHARD_SYNC_BUNDLE_IMG = $(IMAGE_BASE)/cos-fleetshard-sync-bundle:$(COS_FLEETSHARD_SYNC_VERSION)
COS_FLEETSHARD_OPERATOR_CAMEL_BUNDLE_IMG = $(IMAGE_BASE)/cos-fleetshard-operator-camel-bundle:$(COS_FLEETSHARD_OPERATOR_CAMEL_VERSION)
COS_FLEETSHARD_OPERATOR_DEBEZIUM_BUNDLE_IMG = $(IMAGE_BASE)/cos-fleetshard-operator-debezium-bundle:$(COS_FLEETSHARD_OPERATOR_DEBEZIUM_VERSION)
CAMEL_K_OPERATOR_BUNDLE_IMG = $(IMAGE_BASE)/camel-k-operator-bundle:$(CAMEL_K_OPERATOR_VERSION)
STRIMZI_OPERATOR_BUNDLE_IMG = $(IMAGE_BASE)/strimzi-kafka-operator-bundle:$(STRIMZI_OPERATOR_VERSION)
ADDON_BUNDLES_FOLDER = ../managed-tenants-bundles/addons/connectors-operator
CATALOG_IMG = $(IMAGE_BASE)/addon-connectors-operator-catalog

.PHONY: bundle-build
bundle-build:
	docker build -f docker/cos-fleetshard-sync.Dockerfile -t $(COS_FLEETSHARD_SYNC_BUNDLE_IMG) $(ADDON_BUNDLES_FOLDER)/main/$(COS_FLEETSHARD_SYNC_VERSION)
	docker build -f docker/cos-fleetshard-operator-camel.Dockerfile -t $(COS_FLEETSHARD_OPERATOR_CAMEL_BUNDLE_IMG) $(ADDON_BUNDLES_FOLDER)/cos-fleetshard-operator-camel/$(COS_FLEETSHARD_OPERATOR_CAMEL_VERSION)
	docker build -f docker/cos-fleetshard-operator-debezium.Dockerfile -t $(COS_FLEETSHARD_OPERATOR_DEBEZIUM_BUNDLE_IMG) $(ADDON_BUNDLES_FOLDER)/cos-fleetshard-operator-debezium/$(COS_FLEETSHARD_OPERATOR_DEBEZIUM_VERSION)
	docker build -f docker/camel-k-operator.Dockerfile -t $(CAMEL_K_OPERATOR_BUNDLE_IMG) $(ADDON_BUNDLES_FOLDER)/camel-k-operator/$(CAMEL_K_OPERATOR_VERSION)
	docker build -f docker/strimzi-kafka-operator.Dockerfile -t $(STRIMZI_OPERATOR_BUNDLE_IMG) $(ADDON_BUNDLES_FOLDER)/strimzi-kafka-operator/$(STRIMZI_OPERATOR_VERSION)

.PHONY: bundle-push
bundle-push:
	docker push ${COS_FLEETSHARD_SYNC_BUNDLE_IMG}
	docker push ${COS_FLEETSHARD_OPERATOR_CAMEL_BUNDLE_IMG}
	docker push ${COS_FLEETSHARD_OPERATOR_DEBEZIUM_BUNDLE_IMG}
	docker push ${CAMEL_K_OPERATOR_BUNDLE_IMG}
	docker push ${STRIMZI_OPERATOR_BUNDLE_IMG}

.PHONY: opm
OPM = ./bin/opm
opm: ## Download opm locally if necessary.
ifeq (,$(wildcard $(OPM)))
ifeq (,$(shell which opm 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(OPM)) ;\
	OS=$(shell go env GOOS) && ARCH=$(shell go env GOARCH) && \
	curl -sSLo $(OPM) https://github.com/operator-framework/operator-registry/releases/download/v1.18.0/$${OS}-$${ARCH}-opm ;\
	chmod +x $(OPM) ;\
	}
else
OPM = $(shell which opm)
endif
endif

.PHONY: catalog-build
catalog-build: opm
	$(OPM) index add --container-tool docker --tag $(CATALOG_IMG) --bundles $(COS_FLEETSHARD_SYNC_BUNDLE_IMG),$(COS_FLEETSHARD_OPERATOR_CAMEL_BUNDLE_IMG),$(COS_FLEETSHARD_OPERATOR_DEBEZIUM_BUNDLE_IMG),$(CAMEL_K_OPERATOR_BUNDLE_IMG),$(STRIMZI_OPERATOR_BUNDLE_IMG)

.PHONY: catalog-push
catalog-push:
	docker push $(CATALOG_IMG)
