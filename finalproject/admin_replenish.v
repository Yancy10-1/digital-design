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

module admin_replenish(
input EN,
input clk,
input [2:0] behavior,
input [5:0] left,
output [7:0] seg_en,
output [7:0] seg_out
);
    //属性  
    wire [7:0] need1; num_display displayleft1({2'b00,2'b11-left[1:0]},need1);
    wire [7:0] need2; num_display displayleft2({2'b00,2'b11-left[3:2]},need2);
    wire [7:0] need3; num_display displayleft3({2'b00,2'b11-left[5:4]},need3);
    
    //字符显示时钟分频（不用改）
    reg clkout;
    reg [31:0] cnt;
    reg [6:0] scan_cnt;//显示不同字符的计数器
    parameter differentcharperiod=200000;
    
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
    parameter n=7'b0110111;
    parameter e=7'b1111011;
    parameter d=7'b1011110;
    
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
            scan_cnt<=24-behavior*8;
            else
            begin
                scan_cnt<=scan_cnt+1;
                if(scan_cnt==31-behavior*8) scan_cnt<=24-behavior*8;
            end
    end
    
    always @(scan_cnt)//显示字符的形状
    begin
            case(scan_cnt)//eg. 1.H1 2 4.left
            0: seg_out_r={1'b0,{d}};//d
            1: seg_out_r={1'b0,{e}};//e
            2: seg_out_r={1'b0,{e}};//e
            3: seg_out_r={1'b0,{n}};//n
            4: seg_out_r=need3;//剩余量
            5: seg_out_r=8'b0100_0000;
            6: seg_out_r={1'b1,{thr}};//H3-3
            7: seg_out_r={1'b0,{H}};//H3-H

            8: seg_out_r={1'b0,{d}};//d
            9: seg_out_r={1'b0,{e}};//e
            10: seg_out_r={1'b0,{e}};//e
            11: seg_out_r={1'b0,{n}};//n
            12: seg_out_r=need2;//剩余量
            13: seg_out_r=8'b0100_0000;
            14: seg_out_r={1'b0,{two}};//H2-2
            15: seg_out_r={1'b0,{H}};//H2-H
    
            16: seg_out_r={1'b0,{d}};//d
            17: seg_out_r={1'b0,{e}};//e
            18: seg_out_r={1'b0,{e}};//e
            19: seg_out_r={1'b0,{n}};//n
            20: seg_out_r=need1;//剩余量
            21: seg_out_r=8'b0100_0000;
            22: seg_out_r={1'b0,{one}};//H1-1
            23: seg_out_r={1'b0,{H}};//H1-H
            endcase
    end
       
    always @(scan_cnt)//显示字符的位置
    begin
            case(scan_cnt%8)
            7'd0:seg_en_r=8'b0000_0001;
            7'd1:seg_en_r=8'b0000_0010;
            7'd2:seg_en_r=8'b0000_0100;
            7'd3:seg_en_r=8'b0000_1000;
            7'd4:seg_en_r=8'b0001_0000;
            7'd5:seg_en_r=8'b0010_0000;
            7'd6:seg_en_r=8'b0100_0000;
            7'd7:seg_en_r=8'b1000_0000;
            default: seg_en_r=8'b0000_0000;
            endcase
    end

endmodule