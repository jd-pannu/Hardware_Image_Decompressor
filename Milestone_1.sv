`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module Milestone_1 (
		input logic Clock_50,
		input logic Resetn,
		
		input logic M1_Start,
		input logic [15:0] SRAM_read_data,
		
		output logic M1_Finish,
		output logic [15:0] M1_write_data,
		output logic [17:0] M1_address,
		output logic M1_we_n

);

M1_SRAM_state_type M1_SRAM_state;

logic [15:0] u_segment_start;
logic [15:0] v_segment_start;
logic [17:0] rgb_segment_start;
logic [15:0] y_offset_counter;
logic [17:0] rgb_offset_counter;
logic [15:0] new_row_offset_counter;
logic left_lead_in;

logic [15:0] Y_reg;
logic [7:0] U_reg;
logic [7:0] V_reg;

logic [7:0] Y_reg_buf;

logic [31:0] Mult1_op_1, Mult1_op_2, Mult1_result;
logic [63:0] Mult1_result_long;
logic [31:0] Mult2_op_1, Mult2_op_2, Mult2_result;
logic [63:0] Mult2_result_long;
logic [31:0] Mult3_op_1, Mult3_op_2, Mult3_result;
logic [63:0] Mult3_result_long;

logic [17:0] CC_a;
logic [17:0] CC_b;
logic [17:0] CC_c;
logic [17:0] CC_d;
logic [17:0] CC_e;

logic [31:0] CC_even_Y_a;
logic [31:0] CC_even_U_b;
logic [31:0] CC_even_V_c;
logic [31:0] CC_even_U_d;
logic [31:0] CC_even_V_e;

logic [31:0] CC_odd_Y_a;
logic [31:0] CC_odd_U_b;
logic [31:0] CC_odd_V_c;
logic [31:0] CC_odd_U_d;
logic [31:0] CC_odd_V_e;

logic [15:0] int_addr_u1;
logic [15:0] int_addr_u2;
logic [15:0] int_addr_u3;
logic [15:0] int_addr_v1;
logic [15:0] int_addr_v2;
logic [15:0] int_addr_v3;

logic [31:0] int_mult_u1_odd;
logic [31:0] int_mult_u2_odd;
logic [31:0] int_mult_u3_odd;
logic [31:0] int_mult_v1_odd;
logic [31:0] int_mult_v2_odd;
logic [31:0] int_mult_v3_odd;

logic [31:0] int_acc_u_odd;
logic [31:0] int_acc_v_odd;

logic [31:0] CC_acc_R_even;
logic [31:0] CC_acc_G_even;
logic [31:0] CC_acc_B_even;
logic [31:0] CC_acc_R_odd;
logic [31:0] CC_acc_G_odd;
logic [31:0] CC_acc_B_odd;

logic [31:0] reg_16a;
logic [31:0] reg_128c;
logic [31:0] reg_128b;
logic [31:0] reg_128e;
logic [31:0] reg_128d;

logic [7:0] int_shift_reg_u [5:0];
logic [7:0] int_shift_reg_v [5:0];

always_ff @ (posedge Clock_50 or negedge Resetn) begin
	if (Resetn == 1'b0) begin
		M1_SRAM_state <= S_IDLE_M1;			
		M1_we_n <= 1'b1;
		M1_Finish <= 1'b0;
		M1_write_data <= 16'd0;
		M1_address <= 18'd0;
		u_segment_start <= 16'd38400;
		v_segment_start <= 16'd57600;
		rgb_segment_start <= 18'd146944;
		y_offset_counter <= 16'd0;
		rgb_offset_counter <= 18'd0;
		new_row_offset_counter <= 16'd0;
		Y_reg <= 16'd0;
		Y_reg_buf <= 8'd0;
		U_reg <= 8'd0;
		V_reg <= 8'd0;
		left_lead_in <= 1'b1;
		CC_a <= 18'd76284;
		CC_b <= -18'd25624;
		CC_c <= 18'd104595;
		CC_d <= 18'd132251;
		CC_e <= -18'd53281;
		Mult1_op_1 <= 32'd0;
		Mult1_op_2 <= 32'd0;

		Mult2_op_1 <= 32'd0;
		Mult2_op_2 <= 32'd0;

		Mult3_op_1 <= 32'd0;
		Mult3_op_2 <= 32'd0;

		CC_even_Y_a <= 32'd0;
		CC_even_U_b <= 32'd0;
		CC_even_V_c <= 32'd0;
		CC_even_U_d <= 32'd0;
		CC_even_V_e <= 32'd0;
		CC_odd_Y_a <= 32'd0;
		CC_odd_U_b <= 32'd0;
		CC_odd_V_c <= 32'd0;
		CC_odd_U_d <= 32'd0;
		CC_odd_V_e <= 32'd0;
		int_addr_u1 <= 16'd0;
		int_addr_u2 <= 16'd0;
		int_addr_u3 <= 16'd0;
		int_addr_v1 <= 16'd0;
		int_addr_v2 <= 16'd0;
		int_addr_v3 <= 16'd0;
		int_mult_u1_odd <= 32'd0;
		int_mult_u2_odd <= 32'd0;
		int_mult_u3_odd <= 32'd0;
		int_mult_v1_odd <= 32'd0;
		int_mult_v2_odd <= 32'd0;
		int_mult_v3_odd <= 32'd0;
		int_acc_u_odd <= 32'd0;
		int_acc_v_odd <= 32'd0;
		CC_acc_R_even <= 32'd0;
		CC_acc_G_even <= 32'd0;
		CC_acc_B_even <= 32'd0;
		CC_acc_R_odd <= 32'd0;
		CC_acc_G_odd <= 32'd0;
		CC_acc_B_odd <= 32'd0;
		reg_128c <= 32'd13388160;
		reg_16a <= 32'd1220544;
		reg_128b <= 32'd3279872;
		reg_128e <= 32'd6819968;
		reg_128d <= 32'd16928128;
		int_shift_reg_u[5] <= 8'd0;
		int_shift_reg_u[4] <= 8'd0;
		int_shift_reg_u[3] <= 8'd0;
		int_shift_reg_u[2] <= 8'd0;
		int_shift_reg_u[1] <= 8'd0;
		int_shift_reg_u[0] <= 8'd0;
		int_shift_reg_v[5] <= 8'd0;
		int_shift_reg_v[4] <= 8'd0;
		int_shift_reg_v[3] <= 8'd0;
		int_shift_reg_v[2] <= 8'd0;
		int_shift_reg_v[1] <= 8'd0;
		int_shift_reg_v[0] <= 8'd0;
	end else begin
		case (M1_SRAM_state)
		
			S_IDLE_M1: begin

				if (M1_Start == 1'b0) begin
					M1_SRAM_state <= S_IDLE_M1;
				end else begin
					M1_SRAM_state <= S_WAIT_NEW_PIXEL_ROW;
				end
			
			end
			
			S_WAIT_NEW_PIXEL_ROW: begin
			
				if (y_offset_counter == 16'd38400) begin
				
					M1_we_n <= 1'b1;
					M1_Finish <= 1'b0;
					M1_write_data <= 16'd0;
					M1_address <= 18'd0;
					u_segment_start <= 16'd38400;
					v_segment_start <= 16'd57600;
					rgb_segment_start <= 18'd146944;
					y_offset_counter <= 16'd0;
					rgb_offset_counter <= 18'd0;
					new_row_offset_counter <= 16'd0;
					Y_reg <= 16'd0;
					Y_reg_buf <= 8'd0;
					U_reg <= 8'd0;
					V_reg <= 8'd0;
					left_lead_in <= 1'b1;
					CC_a <= 18'd76284;
					CC_b <= 18'd25624;
					CC_c <= 18'd104595;
					CC_d <= 18'd132251;
					CC_e <= 18'd53281;
					Mult1_op_1 <= 32'd0;
					Mult1_op_2 <= 32'd0;

					Mult2_op_1 <= 32'd0;
					Mult2_op_2 <= 32'd0;

					Mult3_op_1 <= 32'd0;
					Mult3_op_2 <= 32'd0;

					CC_even_Y_a <= 32'd0;
					CC_even_U_b <= 32'd0;
					CC_even_V_c <= 32'd0;
					CC_even_U_d <= 32'd0;
					CC_even_V_e <= 32'd0;
					CC_odd_Y_a <= 32'd0;
					CC_odd_U_b <= 32'd0;
					CC_odd_V_c <= 32'd0;
					CC_odd_U_d <= 32'd0;
					CC_odd_V_e <= 32'd0;
					int_addr_u1 <= 16'd0;
					int_addr_u2 <= 16'd0;
					int_addr_u3 <= 16'd0;
					int_addr_v1 <= 16'd0;
					int_addr_v2 <= 16'd0;
					int_addr_v3 <= 16'd0;
					int_mult_u1_odd <= 32'd0;
					int_mult_u2_odd <= 32'd0;
					int_mult_u3_odd <= 32'd0;
					int_mult_v1_odd <= 32'd0;
					int_mult_v2_odd <= 32'd0;
					int_mult_v3_odd <= 32'd0;
					int_acc_u_odd <= 32'd0;
					int_acc_v_odd <= 32'd0;
					CC_acc_R_even <= 32'd0;
					CC_acc_G_even <= 32'd0;
					CC_acc_B_even <= 32'd0;
					CC_acc_R_odd <= 32'd0;
					CC_acc_G_odd <= 32'd0;
					CC_acc_B_odd <= 32'd0;
					reg_128c <= 32'd13388160;
					reg_16a <= 32'd1220544;
					reg_128b <= 32'd3279872;
					reg_128e <= 32'd6819968;
					reg_128d <= 32'd16928128;
					int_shift_reg_u[5] <= 8'd0;
					int_shift_reg_u[4] <= 8'd0;
					int_shift_reg_u[3] <= 8'd0;
					int_shift_reg_u[2] <= 8'd0;
					int_shift_reg_u[1] <= 8'd0;
					int_shift_reg_u[0] <= 8'd0;
					int_shift_reg_v[5] <= 8'd0;
					int_shift_reg_v[4] <= 8'd0;
					int_shift_reg_v[3] <= 8'd0;
					int_shift_reg_v[2] <= 8'd0;
					int_shift_reg_v[1] <= 8'd0;
					int_shift_reg_v[0] <= 8'd0;
				
					M1_SRAM_state <= S_M1_DONE;
				end else begin
				
					new_row_offset_counter <= 16'd0;
					int_acc_u_odd <= 32'd0;
					int_acc_v_odd <= 32'd0;
					CC_acc_R_even <= 32'd0;
					CC_acc_G_even <= 32'd0;
					CC_acc_B_even <= 32'd0;
					CC_acc_R_odd <= 32'd0;
					CC_acc_G_odd <= 32'd0;
					CC_acc_B_odd <= 32'd0;
					Mult1_op_1 <= 32'd0;
					Mult1_op_2 <= 32'd0;

					Mult2_op_1 <= 32'd0;
					Mult2_op_2 <= 32'd0;

					Mult3_op_1 <= 32'd0;
					Mult3_op_2 <= 32'd0;

					CC_even_Y_a <= 32'd0;
					CC_even_U_b <= 32'd0;
					CC_even_V_c <= 32'd0;
					CC_even_U_d <= 32'd0;
					CC_even_V_e <= 32'd0;
					CC_odd_Y_a <= 32'd0;
					CC_odd_U_b <= 32'd0;
					CC_odd_V_c <= 32'd0;
					CC_odd_U_d <= 32'd0;
					CC_odd_V_e <= 32'd0;
					Y_reg <= 16'd0;
					Y_reg_buf <= 8'd0;
					U_reg <= 8'd0;
					V_reg <= 8'd0;
					M1_write_data <= 16'd0;
					M1_address <= 18'd0;
					
					M1_SRAM_state <= S_LEAD_IN_DELAY_1;
				end
				M1_we_n <= 1'b1;
			end
			
//------------------------------------LEAD IN---------------------------------------------------------------------------------------------------

			S_LEAD_IN_DELAY_1: begin //S0
				M1_address <= y_offset_counter;
				M1_SRAM_state <= S_LEAD_IN_DELAY_2;
			end
			
			S_LEAD_IN_DELAY_2: begin //S1
				M1_address <= u_segment_start + (y_offset_counter >> 1);
				M1_SRAM_state <= S_LEAD_IN_DELAY_3;
			end
			
			S_LEAD_IN_DELAY_3: begin //S2
				M1_address <= v_segment_start + (y_offset_counter >> 1);
				y_offset_counter <= y_offset_counter + 16'd1;
				new_row_offset_counter <= new_row_offset_counter + 16'd1;
				M1_SRAM_state <= S_LEAD_IN_DELAY_4;
			end
			
			S_LEAD_IN_DELAY_4: begin //S3
				M1_address <= u_segment_start + (y_offset_counter >> 1) + 18'd1;
				Y_reg <= SRAM_read_data;
				M1_SRAM_state <= S_LEAD_IN_DELAY_5;
			end
			
			S_LEAD_IN_DELAY_5: begin //S4
				M1_address <= v_segment_start + (y_offset_counter >> 1) + 18'd1;
				
				U_reg <= SRAM_read_data[15:8];
				
				int_shift_reg_u[5] <= SRAM_read_data[15:8]; //(j-5)
				int_shift_reg_u[4] <= SRAM_read_data[15:8];
				int_shift_reg_u[3] <= SRAM_read_data[15:8];
				int_shift_reg_u[2] <= SRAM_read_data[7:0];
				int_shift_reg_u[1] <= SRAM_read_data[15:8];
				int_shift_reg_u[0] <= SRAM_read_data[15:8]; //(j+5)
				
				M1_SRAM_state <= S_LEAD_IN_DELAY_6;
			end
			
			S_LEAD_IN_DELAY_6: begin //S5
			
				V_reg <= SRAM_read_data[15:8];
				
				int_shift_reg_v[5] <= SRAM_read_data[15:8]; //(j-5)
				int_shift_reg_v[4] <= SRAM_read_data[15:8];
				int_shift_reg_v[3] <= SRAM_read_data[15:8];
				int_shift_reg_v[2] <= SRAM_read_data[7:0];
				int_shift_reg_v[1] <= SRAM_read_data[15:8];
				int_shift_reg_v[0] <= SRAM_read_data[15:8]; //(j+5)
				
				M1_SRAM_state <= S_LEAD_IN_DELAY_7;
			end
			
			S_LEAD_IN_DELAY_7: begin //S6
				
				//int_shift_reg_u[5] <= int_shift_reg_u[3];
				//int_shift_reg_u[4] <= int_shift_reg_u[2];
				//int_shift_reg_u[3] <= int_shift_reg_u[1];
				//int_shift_reg_u[2] <= int_shift_reg_u[0];
				
				
				int_shift_reg_u[1] <= SRAM_read_data[15:8];
				int_shift_reg_u[0] <= SRAM_read_data[7:0]; //(j+5)
				
				M1_SRAM_state <= S_LEAD_IN_DELAY_8;
			end
			
			S_LEAD_IN_DELAY_8: begin //S7
				
				//int_shift_reg_v[5] <= int_shift_reg_v[3];
				//int_shift_reg_v[4] <= int_shift_reg_v[2];
				//int_shift_reg_v[3] <= int_shift_reg_v[1];
				//int_shift_reg_v[2] <= int_shift_reg_v[0];
				
				
				int_shift_reg_v[1] <= SRAM_read_data[15:8];
				int_shift_reg_v[0] <= SRAM_read_data[7:0]; //(j+5)
				
				left_lead_in <= 1'b1;
				
				M1_SRAM_state <= S_CM_0;
			end

//------------------------------------COMMON MODE---------------------------------------------------------------------------------------------------

			S_CM_0: begin //s3
				M1_address <= y_offset_counter;
				
				M1_we_n <= 1'b1;
				
				M1_SRAM_state <= S_CM_1;
			end
			
			S_CM_1: begin //s4
			
				if (new_row_offset_counter >= 16'd157 && new_row_offset_counter <= 16'd160) begin
					if (new_row_offset_counter == 16'd157) begin
						if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
							M1_address <= u_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [15:8]
						end else begin //even situation for U17
							M1_address <= u_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [7:0]
						end
					end else begin
						if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
							M1_address <= u_segment_start + ((y_offset_counter >> 1)); //take [15:8]
						end else begin //even situation for U17
							M1_address <= u_segment_start + ((y_offset_counter >> 1)); //take [7:0]
						end
					end
				end else begin
					if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
						M1_address <= u_segment_start + ((y_offset_counter >> 1) + 18'd2); //take [15:8]
					end else begin //even situation for U17
						M1_address <= u_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [7:0]
					end
				end
				
				Mult1_op_1 <= Y_reg[15:8];
				Mult1_op_2 <= CC_a;
				
				Mult2_op_1 <= V_reg;
				Mult2_op_2 <= CC_c;
				
				Mult3_op_1 <= U_reg;
				Mult3_op_2 <= $signed(CC_b);
				
				int_addr_u1 <= int_shift_reg_u[5] + int_shift_reg_u[0];
				int_addr_u2 <= int_shift_reg_u[4] + int_shift_reg_u[1];
				int_addr_u3 <= int_shift_reg_u[3] + int_shift_reg_u[2];
				
				M1_SRAM_state <= S_CM_2;
			end
			
			S_CM_2: begin //s5
			
				CC_even_Y_a <= Mult1_result; //All mult results need to be used in the equation directly if the needed equation is in the next state or need to be stored in the next state in a register to be used later
				CC_even_V_c <= Mult2_result;
				CC_even_U_b <= Mult3_result;
			
				if (new_row_offset_counter >= 16'd157 && new_row_offset_counter <= 16'd160) begin
					if (new_row_offset_counter == 16'd157) begin
						if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
							M1_address <= v_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [15:8]
						end else begin //even situation for U17
							M1_address <= v_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [7:0]
						end
					end else begin
						if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
							M1_address <= v_segment_start + ((y_offset_counter >> 1)); //take [15:8]
						end else begin //even situation for U17
							M1_address <= v_segment_start + ((y_offset_counter >> 1)); //take [7:0]
						end
					end
				end else begin
					if (y_offset_counter[0] == 1'b1) begin //odd scenario for U17
						M1_address <= v_segment_start + ((y_offset_counter >> 1) + 18'd2); //take [15:8]
					end else begin //even situation for U17
						M1_address <= v_segment_start + ((y_offset_counter >> 1) + 18'd1); //take [7:0]
					end
				end
				
				int_addr_v1 <= int_shift_reg_v[5] + int_shift_reg_v[0];
				int_addr_v2 <= int_shift_reg_v[4] + int_shift_reg_v[1];
				int_addr_v3 <= int_shift_reg_v[3] + int_shift_reg_v[2];
				
				Mult1_op_1 <= 32'd21;
				Mult1_op_2 <= int_addr_u1;
				
				Mult2_op_1 <= 32'd52;
				Mult2_op_2 <= int_addr_u2;
				
				Mult3_op_1 <= 32'd159;
				Mult3_op_2 <= int_addr_u3;
				
				int_acc_u_odd <= 32'd128;
				
				M1_SRAM_state <= S_CM_3;
			end
			
			S_CM_3: begin //s6
			
				if (y_offset_counter[0] == 1'b1) begin //odd scenario for U14
					M1_address <= u_segment_start + ((y_offset_counter >> 1)); //take [15:8]
				end else begin //even situation for U14
					M1_address <= u_segment_start + ((y_offset_counter >> 1)); //take [7:0]
				end
				
				Y_reg_buf <= Y_reg[7:0];
				Y_reg <= SRAM_read_data;
				
				Mult1_op_1 <= 32'd21;
				Mult1_op_2 <= int_addr_v1;
				
				Mult2_op_1 <= 32'd52;
				Mult2_op_2 <= int_addr_v2;
				
				Mult3_op_1 <= 32'd159;
				Mult3_op_2 <= int_addr_v3;
				
				//whenever using int_acc_u_odd use the built in signed function
				int_acc_u_odd <= ((int_acc_u_odd + Mult1_result - Mult2_result + Mult3_result) >> 8);
				
				int_acc_v_odd <= 32'd128;
				
				M1_SRAM_state <= S_CM_4;
			end
			
			S_CM_4: begin //s7
			
				if (y_offset_counter[0] == 1'b1) begin //odd scenario for V14
					M1_address <= v_segment_start + ((y_offset_counter >> 1)); //take [15:8]
				end else begin //even situation for V14
					M1_address <= v_segment_start + ((y_offset_counter >> 1)); //take [7:0]
				end
				
				if (new_row_offset_counter >= 16'd157 && new_row_offset_counter <= 16'd160) begin
					if (y_offset_counter[0] == 1'b1) begin
						int_shift_reg_u[5] <= int_shift_reg_u[4];
						int_shift_reg_u[4] <= int_shift_reg_u[3];
						int_shift_reg_u[3] <= int_shift_reg_u[2];
						int_shift_reg_u[2] <= int_shift_reg_u[1];
						int_shift_reg_u[1] <= int_shift_reg_u[0];
						int_shift_reg_u[0] <= SRAM_read_data[7:0]; //(j+5)
					end else begin
						int_shift_reg_u[5] <= int_shift_reg_u[4];
						int_shift_reg_u[4] <= int_shift_reg_u[3];
						int_shift_reg_u[3] <= int_shift_reg_u[2];
						int_shift_reg_u[2] <= int_shift_reg_u[1];
						int_shift_reg_u[1] <= int_shift_reg_u[0];
						int_shift_reg_u[0] <= SRAM_read_data[7:0]; //(j+5)
					end
				end else begin
					if (y_offset_counter[0] == 1'b1) begin
						int_shift_reg_u[5] <= int_shift_reg_u[4];
						int_shift_reg_u[4] <= int_shift_reg_u[3];
						int_shift_reg_u[3] <= int_shift_reg_u[2];
						int_shift_reg_u[2] <= int_shift_reg_u[1];
						int_shift_reg_u[1] <= int_shift_reg_u[0];
						int_shift_reg_u[0] <= SRAM_read_data[15:8]; //(j+5)
					end else begin
						int_shift_reg_u[5] <= int_shift_reg_u[4];
						int_shift_reg_u[4] <= int_shift_reg_u[3];
						int_shift_reg_u[3] <= int_shift_reg_u[2];
						int_shift_reg_u[2] <= int_shift_reg_u[1];
						int_shift_reg_u[1] <= int_shift_reg_u[0];
						int_shift_reg_u[0] <= SRAM_read_data[7:0]; //(j+5)
					end
				end
				
				Mult1_op_1 <= V_reg;
				Mult1_op_2 <= $signed(CC_e);
				
				Mult2_op_1 <= U_reg;
				Mult2_op_2 <= CC_d;
				
				Mult3_op_1 <= int_acc_u_odd;
				Mult3_op_2 <= CC_d;
				
				int_acc_v_odd <= ((int_acc_v_odd + Mult1_result - Mult2_result + Mult3_result) >> 8);
				
				CC_acc_R_even <= ($signed(CC_even_Y_a - reg_16a + CC_even_V_c - reg_128c) >>> 16);
				
				M1_SRAM_state <= S_CM_5;
			end
			
			S_CM_5: begin //s8
			
				CC_even_U_d <= Mult2_result;
				CC_odd_U_d <= Mult3_result;
			
				if (left_lead_in == 1'b0) begin
					M1_address <= rgb_segment_start + rgb_offset_counter;
					M1_we_n <= 1'b0;
					
					
					if (CC_acc_B_odd[31] == 1'b1 || CC_acc_G_odd[31] == 1'b1) begin // is negative
						if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b1) begin
							M1_write_data <= {8'd0, 8'd0};
						end
						
						if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b0 && CC_acc_G_odd <= 32'd255) begin
							M1_write_data <= {CC_acc_G_odd[7:0], 8'd0};
						end
						if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b0 && CC_acc_G_odd > 32'd255) begin
							M1_write_data <= {8'd255, 8'd0};
						end
						
						if (CC_acc_B_odd[31] == 1'b0 && CC_acc_G_odd[31] == 1'b1 && CC_acc_B_odd <= 32'd255) begin
							M1_write_data <= {8'd0, CC_acc_B_odd[7:0]};
						end
						if (CC_acc_B_odd[31] == 1'b0 && CC_acc_G_odd[31] == 1'b1 && CC_acc_B_odd > 32'd255) begin
							M1_write_data <= {8'd0, 8'd255};
						end
					end else begin
						if (CC_acc_B_odd > 32'd255 || CC_acc_G_odd > 32'd255) begin //is greater than ff
							if (CC_acc_B_odd > 32'd255 && CC_acc_G_odd > 32'd255) begin
								M1_write_data <= {8'd255, 8'd255};
							end
							if (CC_acc_B_odd > 32'd255 && CC_acc_G_odd <= 32'd255) begin
								M1_write_data <= {CC_acc_G_odd[7:0], 8'd255};
							end
							if (CC_acc_B_odd <= 32'd255 && CC_acc_G_odd > 32'd255) begin
								M1_write_data <= {8'd255, CC_acc_B_odd[7:0]};
							end
						end else begin
							M1_write_data <= {CC_acc_G_odd[7:0], CC_acc_B_odd[7:0]}; // og case
						end
					end
					
					
					rgb_offset_counter <= rgb_offset_counter + 18'd1;
				end
				
				if (new_row_offset_counter >= 16'd157 && new_row_offset_counter <= 16'd160) begin
					if (y_offset_counter[0] == 1'b1) begin
						int_shift_reg_v[5] <= int_shift_reg_v[4];
						int_shift_reg_v[4] <= int_shift_reg_v[3];
						int_shift_reg_v[3] <= int_shift_reg_v[2];
						int_shift_reg_v[2] <= int_shift_reg_v[1];
						int_shift_reg_v[1] <= int_shift_reg_v[0];
						int_shift_reg_v[0] <= SRAM_read_data[7:0]; //(j+5)
					end else begin
						int_shift_reg_v[5] <= int_shift_reg_v[4];
						int_shift_reg_v[4] <= int_shift_reg_v[3];
						int_shift_reg_v[3] <= int_shift_reg_v[2];
						int_shift_reg_v[2] <= int_shift_reg_v[1];
						int_shift_reg_v[1] <= int_shift_reg_v[0];
						int_shift_reg_v[0] <= SRAM_read_data[7:0]; //(j+5)
					end
				end else begin
					if (y_offset_counter[0] == 1'b1) begin
						int_shift_reg_v[5] <= int_shift_reg_v[4];
						int_shift_reg_v[4] <= int_shift_reg_v[3];
						int_shift_reg_v[3] <= int_shift_reg_v[2];
						int_shift_reg_v[2] <= int_shift_reg_v[1];
						int_shift_reg_v[1] <= int_shift_reg_v[0];
						int_shift_reg_v[0] <= SRAM_read_data[15:8]; //(j+5)
					end else begin
						int_shift_reg_v[5] <= int_shift_reg_v[4];
						int_shift_reg_v[4] <= int_shift_reg_v[3];
						int_shift_reg_v[3] <= int_shift_reg_v[2];
						int_shift_reg_v[2] <= int_shift_reg_v[1];
						int_shift_reg_v[1] <= int_shift_reg_v[0];
						int_shift_reg_v[0] <= SRAM_read_data[7:0]; //(j+5)
					end
				end
				
				Mult1_op_1 <= Y_reg_buf;
				Mult1_op_2 <= CC_a;
				
				Mult2_op_1 <= int_acc_v_odd;
				Mult2_op_2 <= CC_c;
				
				Mult3_op_1 <= int_acc_u_odd;
				Mult3_op_2 <= $signed(CC_b);
				
				CC_acc_G_even <= ($signed(CC_even_Y_a - reg_16a + CC_even_U_b + reg_128b + Mult1_result + reg_128e) >>> 16);
				
				M1_SRAM_state <= S_CM_6;
			end
			
			S_CM_6: begin //s9
			
				CC_odd_Y_a <= Mult1_result;
				CC_odd_U_b <= Mult3_result;
			
				M1_address <= rgb_segment_start + rgb_offset_counter;
				
				M1_we_n <= 1'b0;
				
				if (CC_acc_G_even[31] == 1'b1 || CC_acc_R_even[31] == 1'b1) begin // is negative
					if (CC_acc_G_even[31] == 1'b1 && CC_acc_R_even[31] == 1'b1) begin
						M1_write_data <= {8'd0, 8'd0};
					end
					
					if (CC_acc_G_even[31] == 1'b1 && CC_acc_R_even[31] == 1'b0 && CC_acc_R_even <= 32'd255) begin
						M1_write_data <= {CC_acc_R_even[7:0], 8'd0};
					end
					if (CC_acc_G_even[31] == 1'b1 && CC_acc_R_even[31] == 1'b0 && CC_acc_R_even > 32'd255) begin
						M1_write_data <= {8'd255, 8'd0};
					end
					
					if (CC_acc_G_even[31] == 1'b0 && CC_acc_R_even[31] == 1'b1 && CC_acc_G_even <= 32'd255) begin
						M1_write_data <= {8'd0, CC_acc_G_even[7:0]};
					end
					if (CC_acc_G_even[31] == 1'b0 && CC_acc_R_even[31] == 1'b1 && CC_acc_G_even > 32'd255) begin
						M1_write_data <= {8'd0, 8'd255};
					end
				end else begin
					if (CC_acc_G_even > 32'd255 || CC_acc_R_even > 32'd255) begin //is greater than ff
						if (CC_acc_G_even > 32'd255 && CC_acc_R_even > 32'd255) begin
							M1_write_data <= {8'd255, 8'd255};
						end
						if (CC_acc_G_even > 32'd255 && CC_acc_R_even <= 32'd255) begin
							M1_write_data <= {CC_acc_R_even[7:0], 8'd255};
						end
						if (CC_acc_G_even <= 32'd255 && CC_acc_R_even > 32'd255) begin
							M1_write_data <= {8'd255, CC_acc_G_even[7:0]};
						end
					end else begin
						M1_write_data <= {CC_acc_R_even[7:0], CC_acc_G_even[7:0]}; // og case
					end
				end
				
				rgb_offset_counter <= rgb_offset_counter + 18'd1;
				
				if (y_offset_counter[0] == 1'b1) begin //odd scenario for U14
					U_reg <= SRAM_read_data[7:0]; //take [15:8]
				end else begin //even situation for U14
					U_reg <= SRAM_read_data[15:8]; //take [7:0]
				end
				
				Mult1_op_1 <= int_acc_v_odd;
				Mult1_op_2 <= $signed(CC_e);
				
				CC_acc_R_odd <= ($signed(Mult1_result - reg_16a + Mult2_result - reg_128c) >>> 16);
				
				CC_acc_B_even <= ($signed(CC_even_Y_a - reg_16a + CC_even_U_d - reg_128d) >>> 16);
		
				CC_acc_B_odd <= ($signed(Mult1_result - reg_16a + CC_odd_U_d - reg_128d) >>> 16);
				
				left_lead_in <= 1'b0; //Guard
				
				M1_SRAM_state <= S_CM_7;
			end
			
			S_CM_7: begin //s10
			
				M1_address <= rgb_segment_start + rgb_offset_counter;
				
				if (CC_acc_R_odd[31] == 1'b1 || CC_acc_B_even[31] == 1'b1) begin // is negative
					if (CC_acc_R_odd[31] == 1'b1 && CC_acc_B_even[31] == 1'b1) begin
						M1_write_data <= {8'd0, 8'd0};
					end
					
					if (CC_acc_R_odd[31] == 1'b1 && CC_acc_B_even[31] == 1'b0 && CC_acc_B_even <= 32'd255) begin
						M1_write_data <= {CC_acc_B_even[7:0], 8'd0};
					end
					if (CC_acc_R_odd[31] == 1'b1 && CC_acc_B_even[31] == 1'b0 && CC_acc_B_even > 32'd255) begin
						M1_write_data <= {8'd255, 8'd0};
					end
					
					if (CC_acc_R_odd[31] == 1'b0 && CC_acc_B_even[31] == 1'b1 && CC_acc_R_odd <= 32'd255) begin
						M1_write_data <= {8'd0, CC_acc_R_odd[7:0]};
					end
					if (CC_acc_R_odd[31] == 1'b0 && CC_acc_B_even[31] == 1'b1 && CC_acc_R_odd > 32'd255) begin
						M1_write_data <= {8'd0, 8'd255};
					end
				end else begin
					if (CC_acc_R_odd > 32'd255 || CC_acc_B_even > 32'd255) begin //is greater than ff
						if (CC_acc_R_odd > 32'd255 && CC_acc_B_even > 32'd255) begin
							M1_write_data <= {8'd255, 8'd255};
						end
						if (CC_acc_R_odd > 32'd255 && CC_acc_B_even <= 32'd255) begin
							M1_write_data <= {CC_acc_B_even[7:0], 8'd255};
						end
						if (CC_acc_R_odd <= 32'd255 && CC_acc_B_even > 32'd255) begin
							M1_write_data <= {8'd255, CC_acc_R_odd[7:0]};
						end
					end else begin
						M1_write_data <= {CC_acc_B_even[7:0], CC_acc_R_odd[7:0]}; // og case
					end
				end
				
				rgb_offset_counter <= rgb_offset_counter + 18'd1;
				
				if (y_offset_counter[0] == 1'b1) begin //odd scenario for V14
					V_reg <= SRAM_read_data[7:0]; //take [15:8]
				end else begin //even situation for V14
					V_reg <= SRAM_read_data[15:8]; //take [7:0]
				end
				
				CC_acc_G_odd <= ($signed(CC_odd_Y_a - reg_16a + CC_odd_U_b + reg_128b + Mult1_result + reg_128e) >>> 16);
				
				y_offset_counter <= y_offset_counter + 16'd1;
				new_row_offset_counter <= new_row_offset_counter + 16'd1;
				
				if (new_row_offset_counter == 16'd160) begin 
					M1_SRAM_state <= S_LEAD_OUT_0; //lead out
				end else begin
					M1_SRAM_state <= S_CM_0; //CM continues
				end
			end

//------------------------------------LEAD OUT---------------------------------------------------------------------------------------------------

			S_LEAD_OUT_0: begin
				
				M1_address <= rgb_segment_start + rgb_offset_counter;
				
				if (CC_acc_B_odd[31] == 1'b1 || CC_acc_G_odd[31] == 1'b1) begin // is negative
					if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b1) begin
						M1_write_data <= {8'd0, 8'd0};
					end
					
					if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b0 && CC_acc_G_odd <= 32'd255) begin
						M1_write_data <= {CC_acc_G_odd[7:0], 8'd0};
					end
					if (CC_acc_B_odd[31] == 1'b1 && CC_acc_G_odd[31] == 1'b0 && CC_acc_G_odd > 32'd255) begin
						M1_write_data <= {8'd255, 8'd0};
					end
					
					if (CC_acc_B_odd[31] == 1'b0 && CC_acc_G_odd[31] == 1'b1 && CC_acc_B_odd <= 32'd255) begin
						M1_write_data <= {8'd0, CC_acc_B_odd[7:0]};
					end
					if (CC_acc_B_odd[31] == 1'b0 && CC_acc_G_odd[31] == 1'b1 && CC_acc_B_odd > 32'd255) begin
						M1_write_data <= {8'd0, 8'd255};
					end
				end else begin
					if (CC_acc_B_odd > 32'd255 || CC_acc_G_odd > 32'd255) begin //is greater than ff
						if (CC_acc_B_odd > 32'd255 && CC_acc_G_odd > 32'd255) begin
							M1_write_data <= {8'd255, 8'd255};
						end
						if (CC_acc_B_odd > 32'd255 && CC_acc_G_odd <= 32'd255) begin
							M1_write_data <= {CC_acc_G_odd[7:0], 8'd255};
						end
						if (CC_acc_B_odd <= 32'd255 && CC_acc_G_odd > 32'd255) begin
							M1_write_data <= {8'd255, CC_acc_B_odd[7:0]};
						end
					end else begin
						M1_write_data <= {CC_acc_G_odd[7:0], CC_acc_B_odd[7:0]}; // og case
					end
				end
				
				rgb_offset_counter <= rgb_offset_counter + 18'd1;
				
				y_offset_counter <= y_offset_counter - 16'd1;
				
				M1_SRAM_state <= S_WAIT_NEW_PIXEL_ROW;
				
			end


			S_M1_DONE: begin
				M1_we_n <= 1'b1;
				M1_Finish <= 1'b1;
				M1_SRAM_state <= S_IDLE_M1;
			end
		
		default: M1_SRAM_state <= S_IDLE_M1;
		endcase
	end
end

assign Mult1_result_long = Mult1_op_1 * Mult1_op_2;
assign Mult1_result = Mult1_result_long[31:0];

assign Mult2_result_long = Mult2_op_1 * Mult2_op_2;
assign Mult2_result = Mult2_result_long[31:0];

assign Mult3_result_long = Mult3_op_1 * Mult3_op_2;
assign Mult3_result = Mult3_result_long[31:0];


endmodule
