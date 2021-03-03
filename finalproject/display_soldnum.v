`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/06 17:53:06
// Design Name: 
// Module Name: rollingcse
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

module display_soldnum(
input EN,
input clk,
input [2:0] behavior,
input [3:0] sold1,
input [3:0] sold2,
output [7:0] seg_en,
output [7:0] seg_out
);
    //属�??  
    wire [7:0] sold1display; num_display displayleft1(sold1,sold1display);
    wire [7:0] sold10display; num_display displayleft2(sold2,sold10display);
    wire [7:0] good; num_display goodnum({1'b0,behavior},good);

    
    //字符显示时钟分频（不用改�?
    reg clkout;
    reg [31:0] cnt;
    reg [6:0] scan_cnt;//显示不同字符的计数器
    parameter differentcharperiod=25000;
    
    //显示
    reg [7:0] seg_out_r;
    reg [7:0] seg_en_r;
    assign seg_out=~seg_out_r;
    assign seg_en=~seg_en_r;
    
    //字符
    parameter one=7'b0000110;
    parameter two=7'b1011011;
    parameter thr=7'b1001111;
    parameter fou=7'b1100110;
    parameter fiv=7'b1101101;
    parameter six=7'b1111100;
    parameter sev=7'b0000111;
    parameter H=7'b1110110;
    
    always @(posedge clk, negedge EN)//分频：为显示不同字符
    begin
            if(!EN)
            begin
                cnt<=32'b0;
                clkout<=0;
            end
            else if(cnt==(differentcharperiod>>1)-1)
            begin
                cnt<=0;
                clkout<=~clkout;
            end
            else
            cnt<=cnt+1;
    end
    
    always @(posedge clkout, negedge EN)//显示不同字符的计数器
    begin
            if(!EN)
            scan_cnt<=0;
            else if(scan_cnt==7) scan_cnt<=0;
            else
            scan_cnt<=scan_cnt+1;
    end
    
    always @(scan_cnt)
    begin
        case(scan_cnt)
        0:seg_en_r=8'b0000_0001;
        1:seg_en_r=8'b0000_0010;
        2:seg_en_r=8'b0000_0100;
        3:seg_en_r=8'b0000_1000;
        4:seg_en_r=8'b0001_0000;
        5:seg_en_r=8'b0010_0000;
        6:seg_en_r=8'b0100_0000;
        7:seg_en_r=8'b1000_0000;
        endcase
    end

    always  @(scan_cnt)
    begin
    case(scan_cnt)
    0:seg_out_r=8'b0000_0000;
    1:seg_out_r=sold1display;
    2:seg_out_r=sold10display;
    3:seg_out_r=8'b0000_0000;
    4:seg_out_r=8'b0000_0000;
    5:seg_out_r=8'b1000_0000;
    6:seg_out_r=good;
    7:seg_out_r={1'b0,H};
    endcase
    end

endmodule