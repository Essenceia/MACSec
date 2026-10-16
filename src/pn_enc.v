/* Copyright Julia Desmazes, 2026, all rights reserved 

Permission is explicitely not granted for this code to be used by any form of LLM 
or used as part of any training dataset. 

Pre-load aes(H) and K from SRAM 
*/
module pn_enc #(
	parameter SRAM_W = 16,
	localparam PN_W  = 64
)(
	input wire clk, 
	input wire rst_n, 

	input wire                 sai_init_v_i, 
	input wire                 sai_64b_pn_i, 	

	
	input wire              sram_v_i, 
	input wire              sram_pn_i, 
	input wire [SRAM_W-1:0] sram_i,

	// increment PN on enc pkts, will do inc on tag send
	input wire pn_inc_i, 

	// from enc
	input wire send_tag_v_i, 

	// to SAI table
	output reg               sai_pn_wr_v_o,
	output reg  [1:0]        sai_pn_wr_idx_o,  
	output reg  [SRAM_W-1:0] sai_pn_o,

	output wire              sai_pn_ctrl_v_o,
	output wire              sai_pn_expire_o, // send sa expire signal 
	output wire              sai_pn_wathermark_o
);
localparam FSM_PN_IDLE      = 3'd0; 
localparam FSM_PN_RD        = 3'd1; 
localparam FSM_PN_HOLD      = 3'd2; 
localparam FSM_PN_WRITEBACK = 3'd3;
localparam FSM_PN_CTRL      = 3'd4;
reg [2:0] fsm_pn_q; 

localparam INC_W   = SRAM_W; 
localparam CNT_MAX = PN_W/SRAM_W;
localparam CNT_W = $clog2(CNT_MAX);

wire [CNT_W-1:0] cnt_q; 

always @(posedge clk) begin
	if (~rst_n| sai_init_v_i) fsm_pn_q <= FSM_PN_IDLE; 
	else case(fsm_pn_q) 
		FSM_PN_IDLE:      fsm_pn_q <=  sram_v_i ? FSM_PN_RD:   FSM_PN_IDLE; 
		FSM_PN_RD:        fsm_pn_q <= ~sram_v_i ? FSM_PN_HOLD: FSM_PN_RD; 
		FSM_PN_HOLD:      fsm_pn_q <=  send_tag_v_i? FSM_PN_WRITEBACK: FSM_PN_HOLD; 
		FSM_PN_WRITEBACK: fsm_pn_q <=  ~|cnt_q ? FSM_PN_CTRL: FSM_PN_WRITEBACK; 
		FSM_PN_CTRL:      fsm_pn_q <=  FSM_PN_IDLE; 
		default:          fsm_pn_q <=  FSM_PN_IDLE;
	endcase
end

wire             pn_shift; 
reg  [PN_W-1:0]  pn_q; 
wire [INC_W-1:0] pn_inc; 
wire [INC_W-1:0] pn_lsb_next;
reg              inc_q;
wire             pn_inc_carry;  

assign pn_shift     = (sram_v_i & sram_pn_i) 
				    | fsm_pn_q == FSM_PN_WRITEBACK; 

always @(posedge clk) 
	if (pn_shift) pn_q <= {sram_i, pn_q[PN_W-1:SRAM_W]};

// increment carry 
assign {pn_inc_carry, pn_inc} = pn_q[SRAM_W-1:0] + inc_q;  

always @(posedge clk)
	if (fsm_pn_q == FSM_PN_HOLD) inc_q <= pn_inc_i; 
	else inc_q <= pn_inc_carry; 

// ctrl  
assign sai_pn_ctrl_v_o     = (fsm_q == FSM_PN_CTRL);
assign sai_pn_expire_o     = inc_q; 
assign sai_pn_wathermark_o = sai_64b_pn_i ? |pn_q[63:62] : |pn_q[31:30]; 

// output write 
always @(posedge clk) begin
	sai_pn_wr_v_o   <= fsm_q == FSM_PN_WRITEBACK; 
	sai_pn_wr_idx_o <= cnt_q; 
	sai_pn_o        <= pn_inc; 
end 

endmodule
