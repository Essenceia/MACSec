import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import enc_config
 
def set_invalid_data(dut): 
	dut.pn_sai_init_v.value = 0	
	dut.pn_sai_64b_pn.value = "X"
	dut.pn_sram_v.value = 0 
	dut.pn_sram_pn.value = "X"
	dut.pn_sram.value = "X"*16
	dut.pn_pn_inc.value = "X"
	dut.pn_enc_sending_tag_v.value = "X"

async def send_config(dut, conf: enc_config):
	dut.pn_sai_init_v.value = 1 
	dut.pn_sai_64b_pn.value = 1 if conf.pn_64b else 0 
	await ClockCycles(dut.clk, 1) 
	dut.pn_sai_init_v.value = 0
	
	raw = conf.raw()
	sram = dut.pn_sram.value
	for i, b in enumerate(raw): 
		dut.pn_sram_v.value = 1 
		dut.pn_sram_pn.value = 1 if i in range(0, 8) else 0 
		sram[15:8] = sram[7:0]
		sram[7:0] = b 
		dut.pn_sram.value = sram 
		if i % 2 == 1: 
			await ClockCycles(dut.clk, 1)
	dut.pn_sram_v.value = 0 
	dut.pn_enc_sending_tag_v.value = 0 
	dut.pn_sram.value = "X"*16
	dut.pn_sram_pn.value = "X"

async def _phony_enc(dut, pkt_l: int): 
	await ClockCycles(dut.clk, pkt_l) 
	dut.pn_enc_sending_tag_v.value = 1 
	await ClockCycles(dut.clk, 16*4)
	dut.pn_enc_sending_tag_v.value = 0 

async def _phony_ctrl(dut, conf: enc_config, pkt_l:int): 
	await ClockCycles(dut.clk, 2)
	dut.pn_pn_inc.value = 1 if conf.enc and pkt_l > 16 else 0 

async def simulate_pkt(dut, conf: enc_config, pkt_l : int): 
	t_ctrl = cocotb.start_soon(_phony_ctrl(dut, conf, pkt_l))
	t_enc = cocotb.start_soon(_phony_enc(dut, pkt_l))
	t_conf = cocotb.start_soon(send_config(dut, conf))
	await t_ctrl
	await t_enc
	await t_conf	
