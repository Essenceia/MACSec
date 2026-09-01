PROJECT_NAME=soc
CONF := conf
WAIVER_FILE := waiver.vlt
SRC_DIR=src
HAZARD_CORE_DIR=hazard3/hdl

# core + utils
HAZARD_DEPS=$(HAZARD_CORE_DIR)/hazard3_core.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_cpu_1port.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_cpu_2port.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_alu.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_branchcmp.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_mul_fast.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_muldiv_seq.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_encode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_priority.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_priority_dynamic.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_priority_encode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_shift_barrel.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_csr.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_decode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_frontend.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_instr_decompress.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_irq_ctrl.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_pmp.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_power_ctrl.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_regfile_1w2r.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_triggers.v

# debug components - TODO replace JTAG
HAZARD_JTAG_DIR=$(HAZARD_CORE_DIR)/debug/dtm
HAZARD_DEPS+=$(HAZARD_JTAG_DIR)/hazard3_jtag_dtm.v
HAZARD_DEPS+=$(HAZARD_JTAG_DIR)/hazard3_jtag_dtm_core.v

# CDC utils 
HAZARD_CDC_DIR=$(HAZARD_CORE_DIR)/debug/cdc
HAZARD_DEPS+=$(HAZARD_CDC_DIR)/hazard3_apb_async_bridge.v
HAZARD_DEPS+=$(HAZARD_CDC_DIR)/hazard3_reset_sync.v
HAZARD_DEPS+=$(HAZARD_CDC_DIR)/hazard3_sync_1bit.v

# DM ? 
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/debug/dm/hazard3_dm.v

RTL_DEPS=$(HAZARD_DEPS)
RTL_DEPS+=$(wildcard $(SRC_DIR)/*.v) 

LINT_FLAGS := -Wall -Wpedantic -Ilib

lint: $(RTL_DEPS)
	verilator $(CONF)/$(WAIVER_FILE) -y $(SRC_DIR) -y $(HAZARD_CORE_DIR) -DVERILATOR_LINT=1 --lint-only $(LINT_FLAGS) --no-timing $^ --top $(PROJECT_NAME)
.PHONY: lint


