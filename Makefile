PROJECT_NAME=pn_enc
CONF := conf
WAIVER_FILE := waiver.vlt
SRC_DIR=src

RTL_DEPS+=$(wildcard $(SRC_DIR)/*.v) 

LINT_FLAGS := -Wall -Wpedantic -Ilib

lint: $(RTL_DEPS)
	verilator $(CONF)/$(WAIVER_FILE) -y $(SRC_DIR) -DVERILATOR_LINT=1 --lint-only $(LINT_FLAGS) --no-timing $^ --top $(PROJECT_NAME)
.PHONY: lint


