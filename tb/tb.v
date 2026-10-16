/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none
`timescale 1ns / 10ps

module tb ();

initial begin
	$dumpfile("tb.vcd");
	$dumpvars(0, tb);
	#1;
end

localparam SRAM_W = 16;

wire clk;
wire rst_n;

wire pn_sai_init_v; 
wire pn_sai_64b_pn;

wire              pn_sram_v; 
wire              pn_sram_pn; 
wire [SRAM_W-1:0] pn_sram;

wire pn_pn_inc; 

wire        pn_enc_sending_tag_v;
wire [31:0] pn_enc_pn;  

wire              pn_sai_pn_wr_v;
wire [3:0]        pn_sai_pn_wr_idx;  
wire [SRAM_W-1:0] pn_sai_pn_wr;

wire pn_sai_pn_ctrl_v;
wire pn_sai_pn_expire;  
wire pn_sai_pn_wathermark;

pn_enc #(.SRAM_W(SRAM_W)) m_pn_enc(
.clk(clk), 
.rst_n(rst_n), 

.sai_init_v_i(pn_sai_init_v), 
.sai_64b_pn_i(pn_sai_64b_pn),

.sram_v_i(pn_sram_v), 
.sram_pn_i(pn_sram_pn), 
.sram_i(pn_sram),

.pn_inc_i(pn_pn_inc), 

.enc_sending_tag_v_i(pn_enc_sending_tag_v),
.enc_pn_o(pn_enc_pn),  

.sai_pn_wr_v_o(pn_sai_pn_wr_v),
.sai_pn_wr_idx_o(pn_sai_pn_wr_idx),  
.sai_pn_wr_o(pn_sai_pn_wr),

.sai_pn_ctrl_v_o(pn_sai_pn_ctrl_v),
.sai_pn_expire_o(pn_sai_pn_expire),  
.sai_pn_wathermark_o(pn_sai_pn_wathermark)
);
endmodule
