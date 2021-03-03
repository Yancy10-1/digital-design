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

//需要传入剩余量
module display_main_machine(
input EN,
input clk,
input [5:0] left,//从0位开始为第一个货物剩余量
output [7:0] seg_en,
output [7:0] seg_out
    );
    //属性
    parameter price1=7'b0110000;//1
    parameter price2=7'b1011011;//2
    parameter price3=7'b1001111;//3
    
    wire [7:0] left1; num_display displayleft1({2'b00,left[1:0]},left1);
    wire [7:0] left2; num_display displayleft2({2'b00,left[3:2]},left2);
    wire [7:0] left3; num_display displayleft3({2'b00,left[5:4]},left3);
    
    //字符显示时钟分频（不用改）
    reg clkout;
    reg [31:0] cnt;
    reg [6:0] scan_cnt;//显示不同字符的计数器
    parameter differentcharperiod=25000;
    
    //滚动相关
    reg [15:0] multiplier;
    reg [6:0] offset;
    
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
    parameter L=7'b0111000;
    parameter e=7'b1111011;
    parameter f=7'b1110001;
    parameter t=7'b1111000;
    
    always @(posedge clk, negedge EN)//分频：为显示不同字符
    begin
        if(!EN)
        begin
            cnt<=32'b0;
            clkout<=0;
            multiplier<=0;
            offset<=0;
        end
        else if(cnt==(differentcharperiod>>1)-1)
        begin
            cnt<=0;
            clkout<=~clkout;
            multiplier<=multiplier+1;
            if(multiplier==2800)
            begin
                multiplier<=0;
                offset<=offset+1;
                if(offset==7'd38) offset<=0;
            end
        end
        else
        cnt<=cnt+1;        
    end
    
    always @(posedge clkout, negedge EN)//显示不同字符的计数器
    begin
        if(!EN)
        scan_cnt<=0;
        else
        begin
            scan_cnt<=scan_cnt+1;
            if(scan_cnt==7'd38) scan_cnt<=7'd0;
        end
    end
    
    always @(scan_cnt)//显示字符的形状
    begin
            case(scan_cnt)//eg. 1.H1 2 4.left
            0: seg_out_r={1'b0,{t}};//d
            1: seg_out_r={1'b0,{f}};//e
            2: seg_out_r={1'b0,{e}};//e
            3: seg_out_r={1'b0,{L}};//n
            4: seg_out_r=left3;//剩余量
            5: seg_out_r=8'b0100_0000;
            6: seg_out_r={1'b0,{price3}};//price3
            7: seg_out_r=8'b0100_0000;
            8: seg_out_r={1'b0,{thr}};//H3-3
            9: seg_out_r={1'b0,{H}};//H3-H
            10: seg_out_r={1'b1,{thr}};//3.
            11: seg_out_r=8'b0000_0000;
            12: seg_out_r=8'b0000_0000;

            13: seg_out_r={1'b0,{t}};//d
            14: seg_out_r={1'b0,{f}};//e
            15: seg_out_r={1'b0,{e}};//e
            16: seg_out_r={1'b0,{L}};//n
            17: seg_out_r=left2;//剩余量
            18: seg_out_r=8'b0100_0000;
            19: seg_out_r={1'b0,{price2}};//price2
            20: seg_out_r=8'b0100_0000;
            21: seg_out_r={1'b0,{two}};//H2-2
            22: seg_out_r={1'b0,{H}};//H2-H
            23: seg_out_r={1'b1,{two}};//2.
            24: seg_out_r=8'b0000_0000;
            25: seg_out_r=8'b0000_0000;
    
            26: seg_out_r={1'b0,{t}};//d
            27: seg_out_r={1'b0,{f}};//e
            28: seg_out_r={1'b0,{e}};//e
            29: seg_out_r={1'b0,{L}};//n
            30: seg_out_r=left1;//剩余量
            31: seg_out_r=8'b0100_0000;
            32: seg_out_r={1'b0,{price1}};//price1
            33: seg_out_r=8'b0100_0000;
            34: seg_out_r={1'b0,{one}};//H1-1
            35: seg_out_r={1'b0,{H}};//H1-H
            36: seg_out_r={1'b1,{one}};//1.
            37: seg_out_r=8'b0000_0000;
            38: seg_out_r=8'b0000_0000;
            endcase
    end
       
    always @(scan_cnt)//显示字符的位置
    begin
            case((scan_cnt+offset)%39)
            7'd31:seg_en_r=8'b0000_0001;
            7'd32:seg_en_r=8'b0000_0010;
            7'd33:seg_en_r=8'b0000_0100;
            7'd34:seg_en_r=8'b0000_1000;
            7'd35:seg_en_r=8'b0001_0000;
            7'd36:seg_en_r=8'b0010_0000;
            7'd37:seg_en_r=8'b0100_0000;
            7'd38:seg_en_r=8'b1000_0000;
            default: seg_en_r=8'b0000_0000;
            endcase
    end
endmodule