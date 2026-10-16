# Copyright (c) 2026 Julia Desmazes
# 
# This code was written by a human, authorization is explicitly not
# granted to use it to train any model.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, with_timeout
from cocotb.types import Logic, LogicArray 

import random 
import asyncio
import time

import pn_enc_utils
import enc_config 
from enc_config import create_random_config

import os

GATES = os.getenv("GATES", False)

CLK_UNIT="ns"
CLK_PERIOD=20
RST_CYCLES=10

if "TEST_ITER" in os.environ:
	TEST_ITER = int(os.environ["TEST_ITER"].lower().strip())
else:
	TEST_ITER = 50

def start_clk(dut):
	clock = Clock(dut.clk, CLK_PERIOD, CLK_UNIT)
	clk_task = cocotb.start_soon(clock.start()) #runs the clock "in the background" 
	return clk_task

def set_random_seed():
	if "SEED" in os.environ:
		seed = int(os.environ["SEED"].lower().strip())
	else:
		seed = time.time_ns()
	cocotb.log.info(f"random seed {seed}")
	random.seed(seed)

# Reset sequence
async def rst(dut, ena=1 ):
	dut.rst_n.value = 0
	clk_task = start_clk(dut)
	await ClockCycles(dut.clk, RST_CYCLES)
	pn_enc_utils.set_invalid_data(dut)
	dut.rst_n.value = 1
	await ClockCycles(dut.clk, 1)
		
@cocotb.test()
async def pn_test_send_config(dut):
	set_random_seed()
	await rst(dut)
	conf = enc_config.create_random_config()
	await pn_enc_utils.send_config(dut, conf)
	assert(dut.pn_enc_pn == conf.pn[4:7])
	
