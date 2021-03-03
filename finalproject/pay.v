`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 08:57:45
// Design Name: 
// Module Name: countdown
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


module pay(
input EN,
input clk,
input [3:0] paidone,
input [3:0] paidten,
input [3:0] costone,
input [3:0] costten,
output [7:0] seg_en,
output [7:0] seg_out
);
    //�ַ���ʾʱ�ӷ�Ƶ�����øģ�
    reg clkout;
    reg [31:0] cnt;
    reg [6:0] scan_cnt;//��ʾ��ͬ�ַ��ļ�����
    parameter differentcharperiod=125000;

    //����ʱ
    reg [31:0] multiplier_timer;
    reg [3:0] onedigit;
    reg [3:0] tendigit; 
    // wire [7:0] onesdigitdisplay;
    wire [7:0] onesdigitdisplay;
    wire [7:0] tensdigitdisplay;
    
    //��ʾ
    reg [7:0] seg_en_r;
    reg [7:0] seg_out_r;
    assign seg_out=~seg_out_r;
    assign seg_en=~seg_en_r;

    //�Ѹ�Ӧ����ʾ
    wire [7:0] paidonedispaly;
    wire [7:0] paidtendispaly;
    wire [7:0] costonedispaly;
    wire [7:0] costtendispaly;

    //����ʱλ��ת��
    num_display transone(onedigit,onesdigitdisplay);
    num_display transten(tendigit,tensdigitdisplay);
    //�Ѹ�Ӧ��ת��
    num_display transone_paid(paidone,paidonedispaly);
    num_display transten_paid(paidten,paidtendispaly);
    num_display transone_cost(costone,costonedispaly);
    num_display tranten_cost(costten,costtendispaly);

    always@(posedge clk,negedge EN)//��Ƶ������
    begin
            if(!EN)
            begin
                clkout<=0;
                cnt<=0;
                multiplier_timer<=1;
                onedigit<=0;
                tendigit<=3;
            end
            else if(cnt==(differentcharperiod>>1)-1)
            begin
                cnt<=0;
                clkout<=~clkout;
                multiplier_timer<=multiplier_timer+1;
                if(multiplier_timer==1600)
                begin
                    multiplier_timer<=1;
                    if(onedigit==0) 
                    begin
                        tendigit<=tendigit-1;
                        onedigit<=9;
                    end
                    else
                    onedigit<=onedigit-1;//Ҫ�ǵ���ʱ��������ô��
                end
            end
            else
            cnt<=cnt+1;
    end

    always @(posedge clkout,negedge EN)
    begin
            if(!EN)
            scan_cnt<=0;
            else if(scan_cnt==15) //�ܹ�16���ַ�
            begin
                scan_cnt<=0;
            end
            else
            scan_cnt<=scan_cnt+1;

    end

//ʹ���ź�
    always @(scan_cnt)
    begin
            case(scan_cnt)
            0: seg_en_r=8'b0000_0001;
            1: seg_en_r=8'b0000_0010;
            2: seg_en_r=8'b0000_0100;
            3: seg_en_r=8'b0000_1000;
            4: seg_en_r=8'b0001_0000;
            5: seg_en_r=8'b0010_0000;
            6 :seg_en_r=8'b0100_0000;
            7:seg_en_r=8'b1000_0000;
            endcase

    end

//��ʾ���ַ�
    always @(scan_cnt)
    begin
            case(scan_cnt)
            0: seg_out_r=onesdigitdisplay;
            1: seg_out_r=tensdigitdisplay;
            2: seg_out_r=8'b0000_0000;
            3: seg_out_r=costonedispaly;
            4: seg_out_r=costtendispaly;
            5: seg_out_r=8'b0000_0000;
            6: seg_out_r=paidonedispaly;
            7: seg_out_r=paidtendispaly;
            endcase
    end
endmodule