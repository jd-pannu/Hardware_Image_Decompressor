`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module Milestone_2 (
		input logic Clock_50,
		input logic Resetn,
		
		input logic M2_Start,
		input logic [15:0] SRAM_read_data,
		
		output logic M2_Finish,
		output logic [15:0] M2_write_data,
		output logic [17:0] M2_address,
		output logic M2_we_n

);

M2_SRAM_state_type M2_SRAM_state;



logic [15:0] col_addr_counter;
logic [15:0] row_addr_counter;
logic [31:0] pre_idct_segment;
logic [15:0] s_fetch_counter;

logic [15:0] dual_port_ram0_addr_s;
logic dual_port_ram0_we_s;
logic [31:0] s_prime_write_data;
logic [31:0] s_prime_read_data;

logic [15:0] dual_port_ram0_addr_s_odd;
logic dual_port_ram0_we_s_odd;
logic [31:0] s_odd_write_data;
logic [31:0] s_odd_read_data;

logic [17:0] ram0_s_read_counter_even;
logic [17:0] ram0_s_read_counter_odd;
logic [15:0] col_compute_T_counter;
logic [15:0] internal_col_compute_T_counter;
logic [15:0] S_prime_0_reg;
logic [15:0] S_prime_1_reg;
logic [15:0] S_prime_2_reg;
logic [15:0] S_prime_3_reg;
logic [15:0] S_prime_4_reg;
logic [15:0] S_prime_5_reg;
logic [15:0] S_prime_6_reg;
logic [15:0] S_prime_7_reg;
logic [31:0] even_T_acc;
logic [31:0] odd_T_acc;
logic [15:0] compute_T_addr_ram1;
logic compute_T_we;
logic [31:0] compute_T_ram1_data_in;
logic [15:0] ram1_compute_T_write_addr_counter;
logic [15:0] compute_T_big_pic_counter;
logic [15:0] compute_T_addr_ram1_odd;
logic compute_T_we_odd;
logic [31:0] compute_T_ram1_data_out_odd;
logic [31:0] compute_T_ram1_data_out_even;

//////////////////////////////////////////////////////////////////////
logic [17:0] ram1_T_read_counter_even;
logic [17:0] ram1_T_read_counter_odd;
logic [15:0] col_compute_S_counter;
logic [15:0] internal_col_compute_S_counter;
logic [15:0] T0_reg;
logic [15:0] T1_reg;
logic [15:0] T2_reg;
logic [15:0] T3_reg;
logic [15:0] T4_reg;
logic [15:0] T5_reg;
logic [15:0] T6_reg;
logic [15:0] T7_reg;
logic [31:0] even_S_acc;
logic [31:0] odd_S_acc;
logic [15:0] compute_S_addr_ram2;
logic compute_S_we;
logic [31:0] compute_S_ram2_data_in;
logic [15:0] ram2_compute_S_write_addr_counter;
logic [15:0] compute_S_big_pic_counter;
logic [15:0] compute_S_addr_ram2_odd;
logic compute_S_we_odd;
logic [31:0] compute_S_ram2_data_out_odd;
logic [31:0] compute_S_ram2_data_out_even;
//////////////////////////////////////////////////////////////////////

logic [5:0] c0_index1_transpose;
logic [5:0] c0_index1;
logic [5:0] c1_index2_transpose;
logic [5:0] c1_index2;
logic [5:0] c2_index3_transpose;
logic [5:0] c2_index3;
logic signed [31:0] C0,C1,C2,C0_T,C1_T,C2_T;

logic [31:0] Mult1_op_1, Mult1_op_2, Mult1_result;
logic [63:0] Mult1_result_long;
logic [31:0] Mult2_op_1, Mult2_op_2, Mult2_result;
logic [63:0] Mult2_result_long;
logic [31:0] Mult3_op_1, Mult3_op_2, Mult3_result;
logic [63:0] Mult3_result_long;



// instantiate RAM0 (S`)
dual_port_RAM0 RAM_inst0 (
	.address_a ( dual_port_ram0_addr_s ),
	.address_b ( dual_port_ram0_addr_s_odd ),
	.clock ( Clock_50 ),
	.data_a ( s_prime_write_data ),
	.data_b ( s_odd_write_data ),
	.wren_a ( dual_port_ram0_we_s ),
	.wren_b ( dual_port_ram0_we_s_odd ),
	.q_a ( s_prime_read_data ),
	.q_b ( s_odd_read_data )
	);
	
	
// instantiate RAM1 (Compute T)
dual_port_RAM1 RAM_inst1 (
	.address_a ( compute_T_addr_ram1 ),
	.address_b ( compute_T_addr_ram1_odd ),
	.clock ( Clock_50 ),
	.data_a ( compute_T_ram1_data_in ),
	.data_b ( 31'd0 ),
	.wren_a ( compute_T_we ),
	.wren_b ( compute_T_we_odd ),
	.q_a ( compute_T_ram1_data_out_even ),
	.q_b ( compute_T_ram1_data_out_odd )
	);
	
	
// instantiate RAM2 (Compute S)
dual_port_RAM2 RAM_inst2 (
	.address_a ( compute_S_addr_ram2 ),
	.address_b ( compute_S_addr_ram2_odd ),
	.clock ( Clock_50 ),
	.data_a ( compute_S_ram2_data_in ),
	.data_b ( 31'd0 ),
	.wren_a ( compute_S_we ),
	.wren_b ( compute_S_we_odd ),
	.q_a ( compute_S_ram2_data_out_even ),
	.q_b ( compute_S_ram2_data_out_odd )
	);
	
	
	

	
	
always_ff @ (posedge Clock_50 or negedge Resetn) begin
	if (Resetn == 1'b0) begin
		M2_Finish <= 1'b0;
		M2_we_n <= 1'b0;
		M2_write_data <= 16'd0;
		M2_address <= 18'd0;
		col_addr_counter <= 16'd0;
		row_addr_counter <= 16'd0;
		s_fetch_counter <= 16'd0;
		pre_idct_segment <= 32'd76800;
		dual_port_ram0_addr_s <= 16'd0;
		dual_port_ram0_we_s <= 1'b0;
		s_prime_write_data <= 32'd0;
		s_prime_read_data <= 32'd0;
		dual_port_ram0_addr_s_odd <= 16'd0;
		dual_port_ram0_we_s_odd <= 1'b0;
		s_odd_write_data <= 32'd0;
		s_odd_read_data <= 32'd0;
		ram0_s_read_counter_even <= 18'd0;
		ram0_s_read_counter_odd <= 18'd1;
		col_compute_T_counter <= 16'd0;
		internal_col_compute_T_counter <= 16'd0;
		S_prime_0_reg <= 16'd0;
		S_prime_1_reg <= 16'd0;
		S_prime_2_reg <= 16'd0;
		S_prime_3_reg <= 16'd0;
		S_prime_4_reg <= 16'd0;
		S_prime_5_reg <= 16'd0;
		S_prime_6_reg <= 16'd0;
		S_prime_7_reg <= 16'd0;
		even_T_acc <= 32'd0;
		odd_T_acc <= 32'd0;
		compute_T_addr_ram1 <= 16'd0;
		compute_T_we <= 1'b0;
		compute_T_ram1_data_in <= 32'd0;
		ram1_compute_T_write_addr_counter <= 16'd0;
		compute_T_big_pic_counter <= 16'd0;
		compute_T_addr_ram1_odd <= 16'd0;
		compute_T_we_odd <= 1'b0;
		compute_T_ram1_data_out_odd <= 32'd0;
		compute_T_ram1_data_out_even <= 32'd0;
		
///////////////////////////////////////////////////////////////////
		ram1_T_read_counter_even <= 18'd0;
		ram1_T_read_counter_odd <= 18'd1;
		col_compute_S_counter <= 16'd0;
		internal_col_compute_S_counter <= 16'd0;
		T0_reg <= 16'd0;
		T1_reg <= 16'd0;
		T2_reg <= 16'd0;
		T3_reg <= 16'd0;
		T4_reg <= 16'd0;
		T5_reg <= 16'd0;
		T6_reg <= 16'd0;
		T7_reg <= 16'd0;
		even_S_acc <= 32'd0;
		odd_S_acc <= 32'd0;
		compute_S_addr_ram2 <= 16'd0;
		compute_S_we <= 1'b0;
		compute_S_ram2_data_in <= 32'd0;
		ram2_compute_S_write_addr_counter <= 16'd0;
		compute_S_big_pic_counter <= 16'd0;
		compute_S_addr_ram2_odd <= 16'd0;
		compute_S_we_odd <= 1'b0;
		compute_S_ram2_data_out_odd <= 32'd0;
		compute_S_ram2_data_out_even <= 32'd0;
////////////////////////////////////////////////////////////////////
		
		c0_index1_transpose <= 6'd0;
		c0_index1 <= 6'd0;
		c1_index2_transpose <= 6'd0;
		c1_index2 <= 6'd0;
		c2_index3_transpose <= 6'd0;
		c2_index3 <= 6'd0;
		Mult1_op_1 <= 32'd0;
		Mult1_op_2 <= 32'd0;
		Mult2_op_1 <= 32'd0;
		Mult2_op_2 <= 32'd0;
		Mult3_op_1 <= 32'd0;
		Mult3_op_2 <= 32'd0;
	end else begin
		case (M2_SRAM_state)
		
			S_IDLE_M2: begin
				
				if (M2_Start == 1'b0) begin
					M2_SRAM_state <= S_IDLE_M2;
				end else begin
					M2_SRAM_state <= S_FETCH_S_0;
				end
				
			end
			
			S_FETCH_S_0: begin
				col_addr_counter <= col_addr_counter + 16'd1;
				M2_address <= pre_idct_segment + (row_addr_counter << 8) + (row_addr_counter << 6) + col_addr_counter; //ADDR = 76800 + 256RA + 64RA + CA
				M2_SRAM_state <= S_FETCH_S_1;
			end
			
			S_FETCH_S_1: begin
				col_addr_counter <= col_addr_counter + 16'd1;
				M2_address <= pre_idct_segment + (row_addr_counter << 8) + (row_addr_counter << 6) + col_addr_counter; //ADDR = 76800 + 256RA + 64RA + CA
				M2_SRAM_state <= S_FETCH_S_2;
			end
			
			S_FETCH_S_2: begin
			
				s_fetch_counter <= s_fetch_counter + 16'd1;
				dual_port_ram0_addr_s <= s_fetch_counter;
				M2_address <= pre_idct_segment + (row_addr_counter << 8) + (row_addr_counter << 6) + col_addr_counter; //ADDR = 76800 + 256RA + 64RA + CA
				
				dual_port_ram0_we_s <= 1'b0;
				
				if (s_fetch_counter < 16'd61) begin
				
					dual_port_ram0_we_s <= 1'b1;
					s_prime_write_data <= $signed(SRAM_read_data);
					
					if (col_addr_counter == 16'd7) begin
						col_addr_counter <= 16'd0;
						row_addr_counter <= row_addr_counter + 16'd1;
						if (row_addr_counter == 16'd7) begin
							row_addr_counter <= 16'd0;
						end
					end
					
					col_addr_counter <= col_addr_counter + 16'd1;
				
					M2_SRAM_state <= S_FETCH_S_2;
				end else begin
					M2_SRAM_state <= S_FETCH_S_3;
				end
				
			end
			
			S_FETCH_S_3: begin
				s_fetch_counter <= s_fetch_counter + 16'd1;
				dual_port_ram0_addr_s <= s_fetch_counter;
				dual_port_ram0_we_s <= 1'b1;
				s_prime_write_data <= $signed(SRAM_read_data);
				M2_SRAM_state <= S_FETCH_S_4;
			end
			
			S_FETCH_S_4: begin
				dual_port_ram0_addr_s <= s_fetch_counter;
				dual_port_ram0_we_s <= 1'b1;
				s_prime_write_data <= $signed(SRAM_read_data);
				M2_SRAM_state <= S_COMPUTE_T_L0;
			end
			
			S_COMPUTE_T_L0: begin
				
				dual_port_ram0_we_s <= 1'b0;
				dual_port_ram0_addr_s <= ram0_s_read_counter_even;
				dual_port_ram0_addr_s_odd <= ram0_s_read_counter_odd;
				
				ram0_s_read_counter_even <= ram0_s_read_counter_even + 18'd2;
				ram0_s_read_counter_odd <= ram0_s_read_counter_odd + 18'd2;
				
				M2_SRAM_state <= S_COMPUTE_T_L1;
			end
			
			S_COMPUTE_T_L1: begin
				
				dual_port_ram0_addr_s <= ram0_s_read_counter_even;
				dual_port_ram0_addr_s_odd <= ram0_s_read_counter_odd;
				
				ram0_s_read_counter_even <= ram0_s_read_counter_even + 18'd2;
				ram0_s_read_counter_odd <= ram0_s_read_counter_odd + 18'd2;
				
				M2_SRAM_state <= S_COMPUTE_T_L2;
			end
			
			S_COMPUTE_T_L2: begin
				
				S_prime_0_reg <= s_prime_read_data[31:16];
				S_prime_1_reg <= s_prime_read_data[15:0];
				S_prime_2_reg <= s_odd_read_data[31:16];
				S_prime_3_reg <= s_odd_read_data[15:0];
				
				M2_SRAM_state <= S_COMPUTE_T_L3;
			end
			
			S_COMPUTE_T_L3: begin
				
				S_prime_4_reg <= s_prime_read_data[31:16];
				S_prime_5_reg <= s_prime_read_data[15:0];
				S_prime_6_reg <= s_odd_read_data[31:16];
				S_prime_7_reg <= s_odd_read_data[15:0];
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				c2_index3_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd2;
				
				internal_col_compute_T_counter <= internal_col_compute_T_counter + 16'd3;
				
				M2_SRAM_state <= S_COMPUTE_T_CC0;
			end
			
			S_COMPUTE_T_CC0: begin
			
				if (col_compute_T_counter >= 16'd2) begin
					odd_T_acc <= ($signed(odd_T_acc + Mult1_result + Mult2_result) >>> 8);
				end
				
				if (compute_T_big_pic_counter == 16'd31) begin
				
					M2_SRAM_state <= S_COMPUTE_T_LO1;
					
				end else begin
				
					if (col_compute_T_counter == 16'd7) begin
						S_prime_4_reg <= s_prime_read_data[31:16];
						S_prime_5_reg <= s_prime_read_data[15:0];
						S_prime_6_reg <= s_odd_read_data[31:16];
						S_prime_7_reg <= s_odd_read_data[15:0];
					end
				
					Mult1_op_1 <= S_prime_0_reg;
					Mult1_op_2 <= C0_T;
					
					Mult2_op_1 <= S_prime_1_reg;
					Mult2_op_2 <= C1_T;
					
					Mult3_op_1 <= S_prime_2_reg;
					Mult3_op_2 <= C2_T;
					
					internal_col_compute_T_counter <= internal_col_compute_T_counter + 16'd3;
					
					c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
					c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
					c2_index3_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd2;
				
					M2_SRAM_state <= S_COMPUTE_T_CC1;
				end
				
			end
			
			S_COMPUTE_T_CC1: begin
			
				if (col_compute_T_counter >= 16'd2) begin
					compute_T_ram1_data_in <= odd_T_acc;
					compute_T_we <= 1'b1;
					compute_T_addr_ram1 <= ram1_compute_T_write_addr_counter;
					ram1_compute_T_write_addr_counter <= ram1_compute_T_write_addr_counter + 16'd1;
					compute_T_big_pic_counter <= compute_T_big_pic_counter + 16'd1;
				end
			
				even_T_acc <= Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= S_prime_3_reg;
				Mult1_op_2 <= C0_T;
				
				Mult2_op_1 <= S_prime_4_reg;
				Mult2_op_2 <= C1_T;
				
				Mult3_op_1 <= S_prime_5_reg;
				Mult3_op_2 <= C2_T;
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				
				col_compute_T_counter <= col_compute_T_counter + 16'd1;
				internal_col_compute_T_counter <= 16'd0;
			
				M2_SRAM_state <= S_COMPUTE_T_CC2;
			end
			
			S_COMPUTE_T_CC2: begin
			
				compute_T_we <= 1'b0;
			
				even_T_acc <= even_T_acc + Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= S_prime_6_reg;
				Mult1_op_2 <= C0_T;
				
				Mult2_op_1 <= S_prime_7_reg;
				Mult2_op_2 <= C1_T;
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				c2_index3_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd2;
				
				internal_col_compute_T_counter <= internal_col_compute_T_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_T_CC3;
			end
			
			S_COMPUTE_T_CC3: begin
			
				if (col_compute_T_counter == 16'd7) begin
					dual_port_ram0_addr_s <= ram0_s_read_counter_even;
					dual_port_ram0_addr_s_odd <= ram0_s_read_counter_odd;
					
					ram0_s_read_counter_even <= ram0_s_read_counter_even + 18'd2;
					ram0_s_read_counter_odd <= ram0_s_read_counter_odd + 18'd2;
				end
			
				even_T_acc <= ($signed(even_T_acc + Mult1_result + Mult2_result) >>> 8);
			
				Mult1_op_1 <= S_prime_0_reg;
				Mult1_op_2 <= C0_T;
				
				Mult2_op_1 <= S_prime_1_reg;
				Mult2_op_2 <= C1_T;
				
				Mult3_op_1 <= S_prime_2_reg;
				Mult3_op_2 <= C2_T;
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				c2_index3_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd2;
				
				internal_col_compute_T_counter <= internal_col_compute_T_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_T_CC4;
			end
			
			S_COMPUTE_T_CC4: begin
			
				compute_T_ram1_data_in <= even_T_acc;
				compute_T_we <= 1'b1;
				compute_T_addr_ram1 <= ram1_compute_T_write_addr_counter;
				ram1_compute_T_write_addr_counter <= ram1_compute_T_write_addr_counter + 16'd1;
				compute_T_big_pic_counter <= compute_T_big_pic_counter + 16'd1;
				
			
				if (col_compute_T_counter == 16'd7) begin
					dual_port_ram0_addr_s <= ram0_s_read_counter_even;
					dual_port_ram0_addr_s_odd <= ram0_s_read_counter_odd;
					
					ram0_s_read_counter_even <= ram0_s_read_counter_even + 18'd2;
					ram0_s_read_counter_odd <= ram0_s_read_counter_odd + 18'd2;
				end
			
				odd_T_acc <= Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= S_prime_3_reg;
				Mult1_op_2 <= C0_T;
				
				Mult2_op_1 <= S_prime_4_reg;
				Mult2_op_2 <= C1_T;
				
				Mult3_op_1 <= S_prime_5_reg;
				Mult3_op_2 <= C2_T;
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				
				col_compute_T_counter <= col_compute_T_counter + 16'd1;
				internal_col_compute_T_counter <= 16'd0;
			
				M2_SRAM_state <= S_COMPUTE_T_CC5;
			end
			
			S_COMPUTE_T_CC5: begin
			
				compute_T_we <= 1'b0;
			
				if (col_compute_T_counter == 16'd7) begin
					col_compute_T_counter <= 16'd0;
					S_prime_0_reg <= s_prime_read_data[31:16];
					S_prime_1_reg <= s_prime_read_data[15:0];
					S_prime_2_reg <= s_odd_read_data[31:16];
					S_prime_3_reg <= s_odd_read_data[15:0];
				end
			
				odd_T_acc <= odd_T_acc + Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= S_prime_6_reg;
				Mult1_op_2 <= C0_T;
				
				Mult2_op_1 <= S_prime_7_reg;
				Mult2_op_2 <= C1_T;
				
				c0_index1_transpose <= internal_col_compute_T_counter + col_compute_T_counter;
				c1_index2_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd1;
				c2_index3_transpose <= internal_col_compute_T_counter + col_compute_T_counter + 16'd2;
				
				internal_col_compute_T_counter <= internal_col_compute_T_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_T_CC0;
			end
			
			S_COMPUTE_T_LO1: begin
			
				if (col_compute_T_counter >= 16'd2) begin
					compute_T_ram1_data_in <= odd_T_acc;
					compute_T_we <= 1'b1;
					compute_T_addr_ram1 <= ram1_compute_T_write_addr_counter;
					ram1_compute_T_write_addr_counter <= ram1_compute_T_write_addr_counter + 16'd1;
					compute_T_big_pic_counter <= compute_T_big_pic_counter + 16'd1;
				end
			
				M2_SRAM_state <= S_COMPUTE_S_L0;
			end
			
			S_COMPUTE_S_L0: begin
				compute_T_we <= 1'b0;
				compute_T_addr_ram1 <= ram1_T_read_counter_even;
				compute_T_addr_ram1_odd <= ram1_T_read_counter_odd;
				
				ram1_T_read_counter_even <= ram1_T_read_counter_even + 18'd2;
				ram1_T_read_counter_odd <= ram1_T_read_counter_odd + 18'd2;
				
				M2_SRAM_state <= S_COMPUTE_S_L1;
			end
			
			S_COMPUTE_S_L1: begin
				
				compute_T_addr_ram1 <= ram1_T_read_counter_even;
				compute_T_addr_ram1_odd <= ram1_T_read_counter_odd;
				
				ram1_T_read_counter_even <= ram1_T_read_counter_even + 18'd2;
				ram1_T_read_counter_odd <= ram1_T_read_counter_odd + 18'd2;
				
				M2_SRAM_state <= S_COMPUTE_S_L2;
			end
			
			S_COMPUTE_S_L2: begin
				
				T0_reg <= compute_T_ram1_data_out_even[31:16];
				T1_reg <= compute_T_ram1_data_out_even[15:0];
				T2_reg <= compute_T_ram1_data_out_odd[31:16];
				T3_reg <= compute_T_ram1_data_out_odd[15:0];
				
				M2_SRAM_state <= S_COMPUTE_S_L3;
			end
			
			S_COMPUTE_S_L3: begin
				
				T4_reg <= compute_T_ram1_data_out_even[31:16];
				T5_reg <= compute_T_ram1_data_out_even[15:0];
				T6_reg <= compute_T_ram1_data_out_odd[31:16];
				T7_reg <= compute_T_ram1_data_out_odd[15:0];
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				c2_index3 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd2;
				
				internal_col_compute_S_counter <= internal_col_compute_S_counter + 16'd3;
				
				M2_SRAM_state <= S_COMPUTE_S_CC0;
			end
			
			S_COMPUTE_S_CC0: begin
			
				if (col_compute_S_counter >= 16'd2) begin
					odd_S_acc <= ($signed(odd_S_acc + Mult1_result + Mult2_result) >>> 16);
				end
				
				if (compute_S_big_pic_counter == 16'd31) begin
				
					M2_SRAM_state <= S_COMPUTE_S_LO1;
					
				end else begin
				
					if (col_compute_S_counter == 16'd7) begin
						T4_reg <= compute_T_ram1_data_out_even[31:16];
						T5_reg <= compute_T_ram1_data_out_even[15:0];
						T6_reg <= compute_T_ram1_data_out_odd[31:16];
						T7_reg <= compute_T_ram1_data_out_odd[15:0];
					end
				
					Mult1_op_1 <= T0_reg;
					Mult1_op_2 <= C0;
					
					Mult2_op_1 <= T1_reg;
					Mult2_op_2 <= C1;
					
					Mult3_op_1 <= T2_reg;
					Mult3_op_2 <= C2;
					
					internal_col_compute_S_counter <= internal_col_compute_S_counter + 16'd3;
					
					c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
					c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
					c2_index3 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd2;
				
					M2_SRAM_state <= S_COMPUTE_S_CC1;
				end
				
			end
			
			S_COMPUTE_S_CC1: begin
			
				if (col_compute_S_counter >= 16'd2) begin
					compute_S_ram2_data_in <= odd_S_acc;
					compute_S_we <= 1'b1;
					compute_S_addr_ram2 <= ram2_compute_S_write_addr_counter;
					ram2_compute_S_write_addr_counter <= ram2_compute_S_write_addr_counter + 16'd1;
					compute_S_big_pic_counter <= compute_S_big_pic_counter + 16'd1;
				end
			
				even_S_acc <= Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= T3_reg;
				Mult1_op_2 <= C0;
				
				Mult2_op_1 <= T4_reg;
				Mult2_op_2 <= C1;
				
				Mult3_op_1 <= T5_reg;
				Mult3_op_2 <= C2;
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				
				col_compute_S_counter <= col_compute_S_counter + 16'd1;
				internal_col_compute_S_counter <= 16'd0;
			
				M2_SRAM_state <= S_COMPUTE_S_CC2;
			end
			
			S_COMPUTE_S_CC2: begin
			
				compute_S_we <= 1'b0;
			
				even_S_acc <= even_S_acc + Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= T6_reg;
				Mult1_op_2 <= C0;
				
				Mult2_op_1 <= T7_reg;
				Mult2_op_2 <= C1;
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				c2_index3 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd2;
				
				internal_col_compute_S_counter <= internal_col_compute_S_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_S_CC3;
			end
			
			S_COMPUTE_S_CC3: begin
			
				if (col_compute_S_counter == 16'd7) begin
					compute_T_addr_ram1 <= ram1_T_read_counter_even;
					compute_T_addr_ram1_odd <= ram1_T_read_counter_odd;
					
					ram1_T_read_counter_even <= ram1_T_read_counter_even + 18'd2;
					ram1_T_read_counter_odd <= ram1_T_read_counter_odd + 18'd2;
				end
			
				even_S_acc <= ($signed(even_S_acc + Mult1_result + Mult2_result) >>> 16);
			
				Mult1_op_1 <= T0_reg;
				Mult1_op_2 <= C0;
				
				Mult2_op_1 <= T1_reg;
				Mult2_op_2 <= C1;
				
				Mult3_op_1 <= T2_reg;
				Mult3_op_2 <= C2;
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				c2_index3 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd2;
				
				internal_col_compute_S_counter <= internal_col_compute_S_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_S_CC4;
			end
			
			S_COMPUTE_S_CC4: begin
			
				compute_S_ram2_data_in <= even_S_acc;
				compute_S_we <= 1'b1;
				compute_S_addr_ram2 <= ram2_compute_S_write_addr_counter;
				ram2_compute_S_write_addr_counter <= ram2_compute_S_write_addr_counter + 16'd1;
				compute_S_big_pic_counter <= compute_S_big_pic_counter + 16'd1;
				
			
				if (col_compute_S_counter == 16'd7) begin
					compute_T_addr_ram1 <= ram1_T_read_counter_even;
					compute_T_addr_ram1_odd <= ram1_T_read_counter_odd;
					
					ram1_T_read_counter_even <= ram1_T_read_counter_even + 18'd2;
					ram1_T_read_counter_odd <= ram1_T_read_counter_odd + 18'd2;
				end
			
				odd_S_acc <= Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= T3_reg;
				Mult1_op_2 <= C0;
				
				Mult2_op_1 <= T4_reg;
				Mult2_op_2 <= C1;
				
				Mult3_op_1 <= T5_reg;
				Mult3_op_2 <= C2;
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				
				col_compute_S_counter <= col_compute_S_counter + 16'd1;
				internal_col_compute_S_counter <= 16'd0;
			
				M2_SRAM_state <= S_COMPUTE_S_CC5;
			end
			
			S_COMPUTE_S_CC5: begin
			
				compute_S_we <= 1'b0;
			
				if (col_compute_S_counter == 16'd7) begin
					col_compute_S_counter <= 16'd0;
					T0_reg <= compute_T_ram1_data_out_even[31:16];
					T1_reg <= compute_T_ram1_data_out_even[15:0];
					T2_reg <= compute_T_ram1_data_out_odd[31:16];
					T3_reg <= compute_T_ram1_data_out_odd[15:0];
				end
			
				odd_S_acc <= odd_S_acc + Mult1_result + Mult2_result + Mult3_result;
			
				Mult1_op_1 <= T6_reg;
				Mult1_op_2 <= C0;
				
				Mult2_op_1 <= T7_reg;
				Mult2_op_2 <= C1;
				
				c0_index1 <= internal_col_compute_S_counter + col_compute_S_counter;
				c1_index2 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd1;
				c2_index3 <= internal_col_compute_S_counter + col_compute_S_counter + 16'd2;
				
				internal_col_compute_S_counter <= internal_col_compute_S_counter + 16'd3;
			
				M2_SRAM_state <= S_COMPUTE_S_CC0;
			end
			
			S_COMPUTE_S_LO1: begin
			
				if (col_compute_S_counter >= 16'd2) begin
					compute_S_ram2_data_in <= odd_S_acc;
					compute_S_we <= 1'b1;
					compute_S_addr_ram2 <= ram2_compute_S_write_addr_counter;
					ram2_compute_S_write_addr_counter <= ram2_compute_S_write_addr_counter + 16'd1;
					compute_S_big_pic_counter <= compute_S_big_pic_counter + 16'd1;
				end
			
				M2_SRAM_state <= S_M2_DONE;
			end
			
			S_M2_DONE: begin
				M2_we_n <= 1'b1;
				M2_Finish <= 1'b1;
				M2_SRAM_state <= S_IDLE_M2;
			end
		
		default: M2_SRAM_state <= S_IDLE_M2;
		endcase
	end
end

assign Mult1_result_long = Mult1_op_1 * Mult1_op_2;
assign Mult1_result = Mult1_result_long[31:0];

assign Mult2_result_long = Mult2_op_1 * Mult2_op_2;
assign Mult2_result = Mult2_result_long[31:0];

assign Mult3_result_long = Mult3_op_1 * Mult3_op_2;
assign Mult3_result = Mult3_result_long[31:0];

always_comb begin
	case(c0_index1)
		0:   C0 = $signed(32'd1448);   //C00
		1:   C0 = $signed(32'd1448);   //C01
		2:   C0 = $signed(32'd1448);   //C02
		3:   C0 = $signed(32'd1448);   //C03
		4:   C0 = $signed(32'd1448);   //C04
		5:   C0 = $signed(32'd1448);   //C05
		6:   C0 = $signed(32'd1448);   //C06
		7:   C0 = $signed(32'd1448);   //C07
		8:   C0 = $signed(32'd2008);   //C10
		9:   C0 = $signed(32'd1702);   //C11
		10:  C0 = $signed(32'd1137);   //C12
		11:  C0 = $signed(32'd399);    //C13
		12:  C0 = $signed(-32'd399);   //C14
		13:  C0 = $signed(-32'd1137);  //C15
		14:  C0 = $signed(-32'd1702);  //C16
		15:  C0 = $signed(-32'd2008);  //C17
		16:  C0 = $signed(32'd1892);   //C20
		17:  C0 = $signed(32'd783);    //C21
		18:  C0 = $signed(-32'd783);   //C22
		19:  C0 = $signed(-32'd1892);  //C23
		20:  C0 = $signed(-32'd1892);  //C24
		21:  C0 = $signed(-32'd783);   //C25
		22:  C0 = $signed(32'd783);    //C26
		23:  C0 = $signed(32'd1892);   //C27
		24:  C0 = $signed(32'd1702);   //C30
		25:  C0 = $signed(-32'd399);   //C31
		26:  C0 = $signed(-32'd2008);  //C32
		27:  C0 = $signed(-32'd1137);  //C33
		28:  C0 = $signed(32'd1137);   //C34
		29:  C0 = $signed(32'd2008);   //C35
		30:  C0 = $signed(32'd399);    //C36
		31:  C0 = $signed(-32'd1702);  //C37
		32:  C0 = $signed(32'd1448);   //C40
		33:  C0 = $signed(-32'd1448);  //C41
		34:  C0 = $signed(-32'd1448);  //C42
		35:  C0 = $signed(32'd1448);   //C43
		36:  C0 = $signed(32'd1448);   //C44
		37:  C0 = $signed(-32'd1448);  //C45
		38:  C0 = $signed(-32'd1448);  //C46
		39:  C0 = $signed(32'd1448);   //C47
		40:  C0 = $signed(32'd1137);   //C50
		41:  C0 = $signed(-32'd2008);  //C51
		42:  C0 = $signed(32'd399);    //C52
		43:  C0 = $signed(32'd1702);   //C53
		44:  C0 = $signed(-32'd1702);  //C54
		45:  C0 = $signed(-32'd399);   //C55
		46:  C0 = $signed(32'd2008);   //C56
		47:  C0 = $signed(-32'd1137);  //C57
		48:  C0 = $signed(32'd783);    //C60
		49:  C0 = $signed(-32'd1892);  //C61
		50:  C0 = $signed(32'd1892);   //C62
		51:  C0 = $signed(-32'd783);   //C63
		52:  C0 = $signed(-32'd783);   //C64
		53:  C0 = $signed(32'd1892);   //C65
		54:  C0 = $signed(-32'd1892);  //C66
		55:  C0 = $signed(32'd783);    //C67
		56:  C0 = $signed(32'd399);    //C70
		57:  C0 = $signed(-32'd1137);  //C71
		58:  C0 = $signed(32'd1702);   //C72
		59:  C0 = $signed(-32'd2008);  //C73
		60:  C0 = $signed(32'd2008);   //C74
		61:  C0 = $signed(-32'd1702);  //C75
		62:  C0 = $signed(32'd1137);   //C76
		63:  C0 = $signed(-32'd399);   //C77
	endcase
end

always_comb begin
	case(c0_index1_transpose)
		0:   C0_T = $signed(32'd1448);   //C00
		1:   C0_T = $signed(32'd2008);   //C10
		2:   C0_T = $signed(32'd1892);   //C20
		3:   C0_T = $signed(32'd1702);   //C30
		4:   C0_T = $signed(32'd1448);   //C40
		5:   C0_T = $signed(32'd1137);   //C50
		6:   C0_T = $signed(32'd783);    //C60
		7:   C0_T = $signed(32'd399);    //C70
		8:   C0_T = $signed(32'd1448);   //C01
		9:   C0_T = $signed(32'd1702);   //C11
		10:  C0_T = $signed(32'd783);    //C21
		11:  C0_T = $signed(-32'd399);   //C31
		12:  C0_T = $signed(-32'd1448);  //C41
		13:  C0_T = $signed(-32'd2008);  //C51
		14:  C0_T = $signed(-32'd1892);  //C61
		15:  C0_T = $signed(-32'd1137);  //C71
		16:  C0_T = $signed(32'd1448);   //C02
		17:  C0_T = $signed(32'd1137);   //C12
		18:  C0_T = $signed(-32'd783);   //C22
		19:  C0_T = $signed(-32'd2008);  //C32
		20:  C0_T = $signed(-32'd1448);  //C42
		21:  C0_T = $signed(32'd399);    //C52
		22:  C0_T = $signed(32'd1892);   //C62
		23:  C0_T = $signed(32'd1702);   //C72
		24:  C0_T = $signed(32'd1448);   //C03
		25:  C0_T = $signed(32'd399);    //C13
		26:  C0_T = $signed(-32'd1892);  //C23
		27:  C0_T = $signed(-32'd1137);  //C33
		28:  C0_T = $signed(32'd1448);   //C43
		29:  C0_T = $signed(32'd1702);   //C53
		30:  C0_T = $signed(-32'd783);   //C63
		31:  C0_T = $signed(-32'd2008);  //C73
		32:  C0_T = $signed(32'd1448);   //C04
		33:  C0_T = $signed(-32'd399);   //C14
		34:  C0_T = $signed(-32'd1892);  //C24
		35:  C0_T = $signed(32'd1137);   //C34
		36:  C0_T = $signed(32'd1448);   //C44
		37:  C0_T = $signed(-32'd1702);  //C54
		38:  C0_T = $signed(-32'd783);   //C64
		39:  C0_T = $signed(32'd2008);   //C74
		40:  C0_T = $signed(32'd1448);   //C05
		41:  C0_T = $signed(-32'd1137);  //C15
		42:  C0_T = $signed(32'd399);    //C25
		43:  C0_T = $signed(32'd2008);   //C35
		44:  C0_T = $signed(-32'd1448);  //C45
		45:  C0_T = $signed(-32'd399);   //C55
		46:  C0_T = $signed(32'd1892);   //C65
		47:  C0_T = $signed(32'd1137);   //C75
		48:  C0_T = $signed(32'd1448);   //C06
		49:  C0_T = $signed(-32'd783);   //C16
		50:  C0_T = $signed(32'd783);    //C26
		51:  C0_T = $signed(32'd399);    //C36
		52:  C0_T = $signed(-32'd1448);  //C46
		53:  C0_T = $signed(32'd2008);   //C56
		54:  C0_T = $signed(-32'd1892);  //C66
		55:  C0_T = $signed(32'd1137);   //C76
		56:  C0_T = $signed(32'd1448);   //C07
		57:  C0_T = $signed(-32'd2008);  //C17
		58:  C0_T = $signed(32'd1702);   //C27
		59:  C0_T = $signed(-32'd399);   //C37
		60:  C0_T = $signed(32'd1448);   //C47
		61:  C0_T = $signed(-32'd1137);  //C57
		62:  C0_T = $signed(32'd783);    //C67
		63:  C0_T = $signed(-32'd399);   //C77
	endcase
end

always_comb begin
	case(c1_index2)
		0:   C1 = $signed(32'd1448);   //C10
		1:   C1 = $signed(32'd1448);   //C11
		2:   C1 = $signed(32'd1448);   //C12
		3:   C1 = $signed(32'd1448);   //C13
		4:   C1 = $signed(32'd1448);   //C14
		5:   C1 = $signed(32'd1448);   //C15
		6:   C1 = $signed(32'd1448);   //C16
		7:   C1 = $signed(32'd1448);   //C17
		8:   C1 = $signed(32'd2008);   //C20
		9:   C1 = $signed(32'd1702);   //C21
		10:  C1 = $signed(32'd1137);   //C22
		11:  C1 = $signed(32'd399);    //C23
		12:  C1 = $signed(-32'd399);   //C24
		13:  C1 = $signed(-32'd1137);  //C25
		14:  C1 = $signed(-32'd1702);  //C26
		15:  C1 = $signed(-32'd2008);  //C27
		16:  C1 = $signed(32'd1892);   //C30
		17:  C1 = $signed(32'd783);    //C31
		18:  C1 = $signed(-32'd783);   //C32
		19:  C1 = $signed(-32'd1892);  //C33
		20:  C1 = $signed(-32'd1892);  //C34
		21:  C1 = $signed(-32'd783);   //C35
		22:  C1 = $signed(32'd783);    //C36
		23:  C1 = $signed(32'd1892);   //C37
		24:  C1 = $signed(32'd1702);   //C40
		25:  C1 = $signed(-32'd399);   //C41
		26:  C1 = $signed(-32'd2008);  //C42
		27:  C1 = $signed(-32'd1137);  //C43
		28:  C1 = $signed(32'd1137);   //C44
		29:  C1 = $signed(32'd2008);   //C45
		30:  C1 = $signed(32'd399);    //C46
		31:  C1 = $signed(-32'd1702);  //C47
		32:  C1 = $signed(32'd1448);   //C50
		33:  C1 = $signed(-32'd1448);  //C51
		34:  C1 = $signed(-32'd1448);  //C52
		35:  C1 = $signed(32'd1448);   //C53
		36:  C1 = $signed(32'd1448);   //C54
		37:  C1 = $signed(-32'd1448);  //C55
		38:  C1 = $signed(-32'd1448);  //C56
		39:  C1 = $signed(32'd1448);   //C57
		40:  C1 = $signed(32'd1137);   //C60
		41:  C1 = $signed(-32'd2008);  //C61
		42:  C1 = $signed(32'd399);    //C62
		43:  C1 = $signed(32'd1702);   //C63
		44:  C1 = $signed(-32'd1702);  //C64
		45:  C1 = $signed(-32'd399);   //C65
		46:  C1 = $signed(32'd2008);   //C66
		47:  C1 = $signed(-32'd1137);  //C67
		48:  C1 = $signed(32'd783);    //C70
		49:  C1 = $signed(-32'd1892);  //C71
		50:  C1 = $signed(32'd1892);   //C72
		51:  C1 = $signed(-32'd783);   //C73
		52:  C1 = $signed(-32'd783);   //C74
		53:  C1 = $signed(32'd1892);   //C75
		54:  C1 = $signed(-32'd1892);  //C76
		55:  C1 = $signed(32'd783);    //C77
		56:  C1 = $signed(32'd399);    //C80
		57:  C1 = $signed(-32'd1137);  //C81
		58:  C1 = $signed(32'd1702);   //C82
		59:  C1 = $signed(-32'd2008);  //C83
		60:  C1 = $signed(32'd2008);   //C84
		61:  C1 = $signed(-32'd1702);  //C85
		62:  C1 = $signed(32'd1137);   //C86
		63:  C1 = $signed(-32'd399);   //C87
	endcase
end

always_comb begin
	case(c1_index2_transpose)
		0:   C1_T = $signed(32'd1448);   //C10
		1:   C1_T = $signed(32'd2008);   //C20
		2:   C1_T = $signed(32'd1892);   //C30
		3:   C1_T = $signed(32'd1702);   //C40
		4:   C1_T = $signed(32'd1448);   //C50
		5:   C1_T = $signed(32'd1137);   //C60
		6:   C1_T = $signed(32'd783);    //C70
		7:   C1_T = $signed(32'd399);    //C80
		8:   C1_T = $signed(32'd1448);   //C11
		9:   C1_T = $signed(32'd1702);   //C21
		10:  C1_T = $signed(32'd783);    //C31
		11:  C1_T = $signed(-32'd399);   //C41
		12:  C1_T = $signed(-32'd1448);  //C51
		13:  C1_T = $signed(-32'd2008);  //C61
		14:  C1_T = $signed(-32'd1892);  //C71
		15:  C1_T = $signed(-32'd1137);  //C81
		16:  C1_T = $signed(32'd1448);   //C12
		17:  C1_T = $signed(32'd1137);   //C22
		18:  C1_T = $signed(-32'd783);   //C32
		19:  C1_T = $signed(-32'd2008);  //C42
		20:  C1_T = $signed(-32'd1448);  //C52
		21:  C1_T = $signed(32'd399);    //C62
		22:  C1_T = $signed(32'd1892);   //C72
		23:  C1_T = $signed(32'd1702);   //C82
		24:  C1_T = $signed(32'd1448);   //C13
		25:  C1_T = $signed(32'd399);    //C23
		26:  C1_T = $signed(-32'd1892);  //C33
		27:  C1_T = $signed(-32'd1137);  //C43
		28:  C1_T = $signed(32'd1448);   //C53
		29:  C1_T = $signed(32'd1702);   //C63
		30:  C1_T = $signed(-32'd783);   //C73
		31:  C1_T = $signed(-32'd2008);  //C83
		32:  C1_T = $signed(32'd1448);   //C14
		33:  C1_T = $signed(-32'd399);   //C24
		34:  C1_T = $signed(-32'd1892);  //C34
		35:  C1_T = $signed(32'd1137);   //C44
		36:  C1_T = $signed(32'd1448);   //C54
		37:  C1_T = $signed(-32'd1702);  //C64
		38:  C1_T = $signed(-32'd783);   //C74
		39:  C1_T = $signed(32'd2008);   //C84
		40:  C1_T = $signed(32'd1448);   //C15
		41:  C1_T = $signed(-32'd1137);  //C25
		42:  C1_T = $signed(32'd399);    //C35
		43:  C1_T = $signed(32'd2008);   //C45
		44:  C1_T = $signed(-32'd1448);  //C55
		45:  C1_T = $signed(-32'd399);   //C65
		46:  C1_T = $signed(32'd1892);   //C75
		47:  C1_T = $signed(32'd1137);   //C85
		48:  C1_T = $signed(32'd1448);   //C16
		49:  C1_T = $signed(-32'd783);   //C26
		50:  C1_T = $signed(32'd783);    //C36
		51:  C1_T = $signed(32'd399);    //C46
		52:  C1_T = $signed(-32'd1448);  //C56
		53:  C1_T = $signed(32'd2008);   //C66
		54:  C1_T = $signed(-32'd1892);  //C76
		55:  C1_T = $signed(32'd1137);   //C86
		56:  C1_T = $signed(32'd1448);   //C17
		57:  C1_T = $signed(-32'd2008);  //C27
		58:  C1_T = $signed(32'd1702);   //C37
		59:  C1_T = $signed(-32'd399);   //C47
		60:  C1_T = $signed(32'd1448);   //C57
		61:  C1_T = $signed(-32'd1137);  //C67
		62:  C1_T = $signed(32'd783);    //C77
		63:  C1_T = $signed(-32'd399);   //C87
	endcase
end


always_comb begin
	case(c2_index3)
		0:   C2 = $signed(32'd1448);   //C00
		1:   C2 = $signed(32'd1448);   //C01
		2:   C2 = $signed(32'd1448);   //C02
		3:   C2 = $signed(32'd1448);   //C03
		4:   C2 = $signed(32'd1448);   //C04
		5:   C2 = $signed(32'd1448);   //C05
		6:   C2 = $signed(32'd1448);   //C06
		7:   C2 = $signed(32'd1448);   //C07
		8:   C2 = $signed(32'd2008);   //C10
		9:   C2 = $signed(32'd1702);   //C11
		10:  C2 = $signed(32'd1137);   //C12
		11:  C2 = $signed(32'd399);    //C13
		12:  C2 = $signed(-32'd399);   //C14
		13:  C2 = $signed(-32'd1137);  //C15
		14:  C2 = $signed(-32'd1702);  //C16
		15:  C2 = $signed(-32'd2008);  //C17
		16:  C2 = $signed(32'd1892);   //C20
		17:  C2 = $signed(32'd783);    //C21
		18:  C2 = $signed(-32'd783);   //C22
		19:  C2 = $signed(-32'd1892);  //C23
		20:  C2 = $signed(-32'd1892);  //C24
		21:  C2 = $signed(-32'd783);   //C25
		22:  C2 = $signed(32'd783);    //C26
		23:  C2 = $signed(32'd1892);   //C27
		24:  C2 = $signed(32'd1702);   //C30
		25:  C2 = $signed(-32'd399);   //C31
		26:  C2 = $signed(-32'd2008);  //C32
		27:  C2 = $signed(-32'd1137);  //C33
		28:  C2 = $signed(32'd1137);   //C34
		29:  C2 = $signed(32'd2008);   //C35
		30:  C2 = $signed(32'd399);    //C36
		31:  C2 = $signed(-32'd1702);  //C37
		32:  C2 = $signed(32'd1448);   //C40
		33:  C2 = $signed(-32'd1448);  //C41
		34:  C2 = $signed(-32'd1448);  //C42
		35:  C2 = $signed(32'd1448);   //C43
		36:  C2 = $signed(32'd1448);   //C44
		37:  C2 = $signed(-32'd1448);  //C45
		38:  C2 = $signed(-32'd1448);  //C46
		39:  C2 = $signed(32'd1448);   //C47
		40:  C2 = $signed(32'd1137);   //C50
		41:  C2 = $signed(-32'd2008);  //C51
		42:  C2 = $signed(32'd399);    //C52
		43:  C2 = $signed(32'd1702);   //C53
		44:  C2 = $signed(-32'd1702);  //C54
		45:  C2 = $signed(-32'd399);   //C55
		46:  C2 = $signed(32'd2008);   //C56
		47:  C2 = $signed(-32'd1137);  //C57
		48:  C2 = $signed(32'd783);    //C60
		49:  C2 = $signed(-32'd1892);  //C61
		50:  C2 = $signed(32'd1892);   //C62
		51:  C2 = $signed(-32'd783);   //C63
		52:  C2 = $signed(-32'd783);   //C64
		53:  C2 = $signed(32'd1892);   //C65
		54:  C2 = $signed(-32'd1892);  //C66
		55:  C2 = $signed(32'd783);    //C67
		56:  C2 = $signed(32'd399);    //C70
		57:  C2 = $signed(-32'd1137);  //C71
		58:  C2 = $signed(32'd1702);   //C72
		59:  C2 = $signed(-32'd2008);  //C73
		60:  C2 = $signed(32'd2008);   //C74
		61:  C2 = $signed(-32'd1702);  //C75
		62:  C2 = $signed(32'd1137);   //C76
		63:  C2 = $signed(-32'd399);   //C77
	endcase
end

always_comb begin
	case(c2_index3_transpose)
		0:   C2_T = $signed(32'd1448);   //C00
		1:   C2_T = $signed(32'd2008);   //C10
		2:   C2_T = $signed(32'd1892);   //C20
		3:   C2_T = $signed(32'd1702);   //C30
		4:   C2_T = $signed(32'd1448);   //C40
		5:   C2_T = $signed(32'd1137);   //C50
		6:   C2_T = $signed(32'd783);    //C60
		7:   C2_T = $signed(32'd399);    //C70
		8:   C2_T = $signed(32'd1448);   //C01
		9:   C2_T = $signed(32'd1702);   //C11
		10:  C2_T = $signed(32'd783);    //C21
		11:  C2_T = $signed(-32'd399);   //C31
		12:  C2_T = $signed(-32'd1448);  //C41
		13:  C2_T = $signed(-32'd2008);  //C51
		14:  C2_T = $signed(-32'd1892);  //C61
		15:  C2_T = $signed(-32'd1137);  //C71
		16:  C2_T = $signed(32'd1448);   //C02
		17:  C2_T = $signed(32'd1137);   //C12
		18:  C2_T = $signed(-32'd783);   //C22
		19:  C2_T = $signed(-32'd2008);  //C32
		20:  C2_T = $signed(-32'd1448);  //C42
		21:  C2_T = $signed(32'd399);    //C52
		22:  C2_T = $signed(32'd1892);   //C62
		23:  C2_T = $signed(32'd1702);   //C72
		24:  C2_T = $signed(32'd1448);   //C03
		25:  C2_T = $signed(32'd399);    //C13
		26:  C2_T = $signed(-32'd1892);  //C23
		27:  C2_T = $signed(-32'd1137);  //C33
		28:  C2_T = $signed(32'd1448);   //C43
		29:  C2_T = $signed(32'd1702);   //C53
		30:  C2_T = $signed(-32'd783);   //C63
		31:  C2_T = $signed(-32'd2008);  //C73
		32:  C2_T = $signed(32'd1448);   //C04
		33:  C2_T = $signed(-32'd399);   //C14
		34:  C2_T = $signed(-32'd1892);  //C24
		35:  C2_T = $signed(32'd1137);   //C34
		36:  C2_T = $signed(32'd1448);   //C44
		37:  C2_T = $signed(-32'd1702);  //C54
		38:  C2_T = $signed(-32'd783);   //C64
		39:  C2_T = $signed(32'd2008);   //C74
		40:  C2_T = $signed(32'd1448);   //C05
		41:  C2_T = $signed(-32'd1137);  //C15
		42:  C2_T = $signed(32'd399);    //C25
		43:  C2_T = $signed(32'd2008);   //C35
		44:  C2_T = $signed(-32'd1448);  //C45
		45:  C2_T = $signed(-32'd399);   //C55
		46:  C2_T = $signed(32'd1892);   //C65
		47:  C2_T = $signed(32'd1137);   //C75
		48:  C2_T = $signed(32'd1448);   //C06
		49:  C2_T = $signed(-32'd783);   //C16
		50:  C2_T = $signed(32'd783);    //C26
		51:  C2_T = $signed(32'd399);    //C36
		52:  C2_T = $signed(-32'd1448);  //C46
		53:  C2_T = $signed(32'd2008);   //C56
		54:  C2_T = $signed(-32'd1892);  //C66
		55:  C2_T = $signed(32'd1137);   //C76
		56:  C2_T = $signed(32'd1448);   //C07
		57:  C2_T = $signed(-32'd2008);  //C17
		58:  C2_T = $signed(32'd1702);   //C27
		59:  C2_T = $signed(-32'd399);   //C37
		60:  C2_T = $signed(32'd1448);   //C47
		61:  C2_T = $signed(-32'd1137);  //C57
		62:  C2_T = $signed(32'd783);    //C67
		63:  C2_T = $signed(-32'd399);   //C77
	endcase
end


endmodule