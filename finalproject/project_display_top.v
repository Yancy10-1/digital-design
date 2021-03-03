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

//�???要传入剩余量
module project_display_top(
input clk,
input rst,
input isenquire,
input endpay,
input [3:0] adminpasswd,
input issuccessfulpaid,
input [1:0] canintopay,
input [3:0] paidone,
input [3:0] paidten,
input [3:0] costone,
input [3:0] costten,
input [3:0] returnone,
input [3:0] returnten,
input isintoincome,
input [3:0] income1,
input [3:0] income2,
input [3:0] sellnum1,
input [3:0] sellnum10,
input [1:0] choose,//用户选择货道
input [5:0] goodleft,//�???0位开始为第一个货物剩余量
output [7:0] seg_en,
output [7:0] seg_out
    );

    wire [7:0] seg_en_main;
    wire [7:0] seg_out_main;

    wire [7:0] seg_en_select_cust;
    wire [7:0] seg_out_select_cust;

    wire [7:0] seg_en_failintopay;
    wire [7:0] seg_out_failintopay;

    wire [7:0] seg_en_replenish;
    wire [7:0] seg_out_replenish;

    wire [7:0] seg_en_earn;
    wire [7:0] seg_out_earn;

    wire [7:0] seg_en_soldnum;
    wire [7:0] seg_out_soldnum;

    wire [7:0] seg_en_pay;
    wire [7:0] seg_out_pay;

    wire [7:0] seg_en_endpay;
    wire [7:0] seg_out_endpay;

    reg [7:0] pre_seg_en;
    reg [7:0] pre_seg_out;

    reg [10:0] state;
    
    reg [10:0] nostate=11'b000_0000_0000;
    reg [10:0] mainstate=11'b000_0000_0010;
    reg [10:0] custselstate=11'b000_0000_0100;
    reg [10:0] replenishstate=11'b000_0001_0000;
    reg [10:0] earnstate=11'b000_0010_0000;
    reg [10:0] soldstate=11'b000_0100_0000;
    reg [10:0] paystate=11'b000_1000_0000;
    reg [10:0] endpaystate=11'b001_0000_0000;
    reg [10:0] failintopaystate=11'b010_0000_0000;
    reg [10:0] laststate=11'b0_0000_0000;


    always @(posedge clk,negedge rst)
    begin
        if(!rst)
        begin
            state=nostate;
        end
        else
        begin
            if(endpay)
            begin
                state<=endpaystate;
            end
            else if(canintopay==0)
            begin
                state=failintopaystate;
            end
            else if(canintopay==1)
            begin
                state=paystate;
            end
            else if(adminpasswd==4'b1010)
            begin
                if(isintoincome)
                begin
                    state=earnstate;
                end
                else if(~isenquire)
                begin
                    if(choose==0)
                    state=mainstate;
                    else if(choose>=1&&choose<=3)
                    state=soldstate;
                end
                else if(isenquire)
                begin
                    if(choose>=1&&choose<=3)
                    state=replenishstate;
                    else if(choose==0)
                    state=mainstate;
                end
            end
            else if(adminpasswd!=4'b1010)
            begin
                if(isenquire)
                begin
                    if(choose>=1&&choose<=3)
                    state=custselstate;
                    else if(choose==0)
                    state=mainstate;
                end
                else
                state=mainstate;
            end
            else
            state=mainstate;
        end
    end

    always @(state)
    begin
        case(state)
        nostate:
        begin
            pre_seg_en<=8'b0000_0000;
            pre_seg_out<=8'b0000_0000;
        end
        mainstate:
        begin
            pre_seg_en<=seg_en_main;
            pre_seg_out<=seg_out_main;
        end
        custselstate:
        begin
            pre_seg_en<=seg_en_select_cust;
            pre_seg_out<=seg_out_select_cust;
        end
        failintopaystate:
        begin
            pre_seg_en<=seg_en_failintopay;
            pre_seg_out<=seg_out_failintopay;           
        end
        replenishstate:
        begin
            pre_seg_en<=seg_en_replenish;
            pre_seg_out<=seg_out_replenish;
        end
        earnstate:
        begin
            pre_seg_en<=seg_en_earn;
            pre_seg_out<=seg_out_earn;            
        end
        soldstate:
        begin
            pre_seg_en<=seg_en_soldnum;
            pre_seg_out<=seg_out_soldnum;            
        end
        paystate:
        begin
            pre_seg_en<=seg_en_pay;
            pre_seg_out<=seg_out_pay;            
        end
        endpaystate:
        begin
            pre_seg_en<=seg_en_endpay;
            pre_seg_out<=seg_out_endpay; 
        end
        default: 
        begin
            pre_seg_en<=8'b0000_0000;
            pre_seg_out<=8'b0000_0000;
        end
        endcase
    end

    display_main_machine main(state[1],clk,goodleft,seg_en_main,seg_out_main);
    display_custselect_machine select(state[2],clk,choose,goodleft,seg_en_select_cust,seg_out_select_cust);
    failintopay failintopaydisplay(state[9],clk,seg_en_failintopay,seg_out_failintopay);
    pay paydisplay(
        .EN(state[7]),
        .clk(clk),
        .paidone(paidone),
        .paidten(paidten),
        .costone(costone),
        .costten(costten),
        .seg_en(seg_en_pay),
        .seg_out(seg_out_pay)
    );
    endpay endpaydisplay(
        .EN(state[8]),
        .clk(clk),
        .mode(issuccessfulpaid),
        .returnone(returnone),
        .returnten(returnten),
        .seg_en(seg_en_endpay),
        .seg_out(seg_out_endpay)
    );
    admin_replenish replensihdisplay(
        .EN(state[4]),
        .clk(clk),
        .behavior(choose),
        .left(goodleft),
        .seg_en(seg_en_replenish),
        .seg_out(seg_out_replenish)
    );
    earn earndisplay(
        .EN(state[5]),
        .clk(clk),
        .earn({income2,income1}),
        .seg_en(seg_en_earn),
        .seg_out(seg_out_earn)
    );
    display_soldnum soldnumdisplay(
        .EN(state[6]),
        .clk(clk),
        .behavior(choose),
        .sold1(sellnum1),
        .sold2(sellnum10),
        .seg_en(seg_en_soldnum),
        .seg_out(seg_out_soldnum)
    );

    assign seg_en=pre_seg_en;
    assign seg_out=pre_seg_out;

endmodule