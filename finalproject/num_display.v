`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/11 23:15:03
// Design Name: 
// Module Name: num_display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module num_display(
input [3:0] num,
output reg [7:0] display_r
    );
    always @(num)
    begin
    case(num)
    4'b000: display_r=8'b00111111;
    4'b001: display_r=8'b00000110;
    4'b010: display_r=8'b01011011;
    4'b011: display_r=8'b01001111;
    4'b100: display_r=8'b01100110;
    4'b101: display_r=8'b01101101;
    4'b110: display_r=8'b01111100;
    4'b111: display_r=8'b00000111;
    4'b1000: display_r=8'b01111111;
    4'b1001: display_r=8'b01100111;
    endcase
    end
endmodule
