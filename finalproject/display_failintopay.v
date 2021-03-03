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
module failintopay(
input EN,
input clk,
output [7:0] seg_en,
output [7:0] seg_out
);
    //字符显示时钟分频（不用改）
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
    parameter O=7'b0111111;
    parameter L=7'b0111000;
    parameter e=7'b1111011;
    parameter f=7'b1110001;
    parameter t=7'b1111000;
    parameter n=7'b0110111;

    always @(posedge clk, negedge EN)
    begin
        if(!EN)
        begin
            clkout<=0;
            cnt<=0;
        end
        else if(cnt==(differentcharperiod>>1)-1) 
        begin
            clkout<=~clkout;
            cnt<=0;
        end
        else
        cnt<=cnt+1;
    end

    always @(posedge clkout, negedge EN)
    begin
        if(!EN)
        begin
            scan_cnt<=0;
        end
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
        0:seg_out_r={1'b0,t};
        1:seg_out_r={1'b0,f};
        2:seg_out_r={1'b0,e};
        3:seg_out_r={1'b0,L};
        4:seg_out_r=8'b0000_0000;
        5:seg_out_r={1'b0,O};
        6:seg_out_r={1'b0,n};
        7:seg_out_r=8'b0000_0000;
        endcase
    end


endmodule