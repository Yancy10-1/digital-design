`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/22 18:57:07
// Design Name: 
// Module Name: machine
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

module machinex(
  input      clk,
  input      rst,
  input      [3:0] row,
  input isenquire,
  input setzero,
  input replenish,//确认补货
  input [1:0] addcount,
  input [3:0] password,
  input [1:0] buynum,
  input [1:0] money,
  output reg [3:0] col,         
  output reg key_pressed_flag,  
  output[7:0]seg_en,
  output[7:0]seg_out,
  output beep
);

reg back;
reg ensure;
reg intoincomedisplay=1'b0;
reg [1:0] keyboard_val;
reg [1:0]count1=2'b11;//��Ʒ1������
reg [1:0]count2=2'b11;
reg [1:0]count3=2'b00;
reg [1:0] price1=1;//单价
reg [1:0] price2=2;
reg [1:0] price3=3;
reg [1:0] price=2'b00;//应付价钱的单�??
wire [3:0] shouldpay;//应付总价
wire [3:0] shouldpay1;
wire [3:0] shouldpay2;
reg [3:0] return;//�??钱�?�价
wire [3:0] returnone;
wire [3:0] returnten;
reg [3:0] sumpaid=4'b0000;//实付
reg issuccessfulpaid=1'b0;

//管理�?
//每个商品卖出数量
reg [3:0] sellnum1=4'b0;
reg [3:0] sellnum2=4'b0;
reg [3:0] sellnum3=4'b0;

reg [3:0] presellnum=4'b0000;
wire [3:0] presellnum1;
wire [3:0] presellnum10;
assign presellnum1=(presellnum>=10?presellnum-10:presellnum);
assign presellnum10=presellnum[3]&(presellnum[2]|presellnum[1]);

//总收�?
reg [3:0] income=4'b0;
wire [3:0] income1;
wire [3:0] income2;
assign income1=(income>=10?income-10:income);
assign income2=income[3]&(income[2]|income[1]);

reg ifhasensure=1'b0;
//应付
assign shouldpay=buynum*price;
assign shouldpay1=(shouldpay>=10?shouldpay-10:shouldpay);
assign shouldpay2=shouldpay[3]&(shouldpay[2]|shouldpay[1]);
assign returnone=(return>=10?return-10:return);
assign returnten=return[3]&(return[2]|return[1]);

reg [1:0]number=2'b00;//货道号�?�择
reg [1:0]lastnumber=2'b00;//记录上一个�?�择的货道号
reg [1:0]precount=2'b00;//货道号的货物�??

reg [1:0] cantopay=2'b10;//是否能进入付款，0为不能进入，1进入�???2无状�???
//倒计�???
reg clkout;
reg [31:0] countdowncnt;
parameter counterdownperiod=100000000*30;
reg endpay=1'b0;

//����

//选择的货道号的货物数�???
always@(posedge clk)
begin
  case (lastnumber)
    1: precount<=count1;
    2: precount<=count2;
    3: precount<=count3; 
    default: precount<=0;
  endcase
end
//选择的货道号单价
always @(posedge clk,negedge rst)
begin
  if(!rst)
  price<=0;
  else
  case(lastnumber)
  1:price<=price1;
  2:price<=price2;
  3:price<=price3;
  default: price<=0;
  endcase
end
//付款
always@(posedge clk,negedge rst)
begin
  if(~rst)
  sumpaid<=0;
  else
  begin
    if(money==2'b01)
    sumpaid=1;
    else if(money==2'b10)
    sumpaid=5;
    else if(money==2'b11)
    sumpaid=10;
    else
    sumpaid=0;
  end
end

//选择查看的货道的总卖出数
always @(posedge clk,negedge rst)
begin
  if(~rst)
  begin
    presellnum<=0;
  end
  else
  case(lastnumber)
  1: presellnum<=sellnum1;
  2: presellnum<=sellnum2;
  3: presellnum<=sellnum3;
  default: presellnum<=0;
  endcase
end

//判断是否要结束付款阶�??
always@(posedge clk, negedge rst)
begin
  if(!rst)
  begin
    countdowncnt<=0;
    clkout<=0;
    endpay<=0;
    issuccessfulpaid<=0;
    return<=0;
    ifhasensure<=0;
  end
  else if(password!=4'b1010)
  begin
    if(cantopay==1&&~endpay)
    begin
      if(countdowncnt==counterdownperiod-1||sumpaid>=shouldpay)
      begin
        endpay<=1;
        if(sumpaid>=shouldpay)
        begin
          return<=sumpaid-shouldpay;
          issuccessfulpaid<=1;  
          if(price==price1)
          begin
            sellnum1<=sellnum1+buynum;
            count1<=count1-buynum;
            income<=income+shouldpay;
          end
          else if(price==price2)
          begin
            sellnum2<=sellnum2+buynum;
            count2<=count2-buynum;
            income<=income+shouldpay;
          end
          else if(price==price3)
          begin
            sellnum3<=sellnum3+buynum;
            count3<=count3-buynum;
            income<=income+shouldpay;
          end      
        end
        else
        return<=sumpaid;
      end
      else
      countdowncnt<=countdowncnt+1;
    end
  end
  else
  begin
    if(setzero)
    begin
      count1<=0;
      count2<=0;
      count3<=0;
    end
    else if(replenish&&~ifhasensure)
    begin
      if(lastnumber==1)//？？？？�?
      begin
        count1<=count1+addcount;
      end
      else if(lastnumber==2)
      begin
        count2<=count2+addcount;
      end
      else if(lastnumber==3)
      begin
        count3<=count3+addcount;
      end
      ifhasensure<=1;
    end
    else if(~replenish)//向下拨也会变
    begin
      ifhasensure<=0;
    end
  end
end


//音效
Bgm used(
.cantopay(cantopay),
.endpay(endpay),

.pay_success(issuccessfulpaid),

  .i_clk(clk),
  .rst(rst),
  .play_Bgm(isenquire),
  .key_pressed(key_pressed_flag),
  .beep(beep)
  );


project_display_top display(
  .clk(clk),
  .rst(rst),
  .isenquire(isenquire),
  .endpay(endpay),
  .adminpasswd(password),
  .issuccessfulpaid(issuccessfulpaid),
  .canintopay(cantopay),
  .paidone(sumpaid%10),
  .paidten(sumpaid/10),
  .costone(shouldpay1),
  .costten(shouldpay2),
  .returnone(returnone),
  .returnten(returnten),
  .isintoincome(intoincomedisplay),
  .income1(income1),
  .income2(income2),
  .sellnum1(presellnum1),
  .sellnum10(presellnum10),
  .choose(number),
  .goodleft({count3,count2,count1}),
  .seg_en(seg_en),
  .seg_out(seg_out)
  );


//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt;                         // ������

always @ (posedge clk, negedge rst)
  if (!rst)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;

wire key_clk = cnt[19];                // (2^20/50M = 21)ms 
//--------------------------------------
// ��Ƶ���� ����
//--------------------------------------

//++++++++++++++++++++++++++++++++++++++
// ״̬������ ��ʼ
//++++++++++++++++++++++++++++++++++++++
// ״̬�����٣����������????
parameter NO_KEY_PRESSED = 6'b000_001;  // û�а�������  
parameter SCAN_COL0      = 6'b000_010;  // ɨ���????0�� 
parameter SCAN_COL1      = 6'b000_100;  // ɨ���????1�� 
parameter SCAN_COL2      = 6'b001_000;  // ɨ���????2�� 
parameter SCAN_COL3      = 6'b010_000;  // ɨ���????3�� 
parameter KEY_PRESSED    = 6'b100_000;  // �а�������

reg [5:0] current_state, next_state;    // ��̬����̬

always @ (posedge key_clk, negedge rst)
  if (!rst)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;

// ��������ת��״̬
always @ *
  case (current_state)
    NO_KEY_PRESSED :                    // û�а�������
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // ɨ���????0�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // ɨ���????1�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // ɨ���????2��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // ɨ���????3��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // �а�������
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase

          // ���̰��±�־
reg [3:0] col_val, row_val;             // ��ֵ����ֵ

// ���ݴ�̬������Ӧ�Ĵ�����ֵ
always @ (posedge key_clk, negedge rst)
  if (!rst)
  begin
    col              <= 4'h0;
    key_pressed_flag <= 0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :              // û�а�������
      begin
        col              <= 4'h0;
        row_val              <=4'hf;
        key_pressed_flag <=    0;       // ����̰��±��?
      end
      SCAN_COL0 :                       // ɨ���????0��
      begin
        col <= 4'b1110;
         row_val              <=4'hf;
        end
      SCAN_COL1 :                       // ɨ���????1��
      begin
        col <= 4'b1101;
         row_val              <=4'hf;
         end
      SCAN_COL2 :                       // ɨ���????2��
      begin
        col <= 4'b1011;
         row_val              <=4'hf;
         end
      SCAN_COL3 :                       // ɨ���????3��
      begin
        col <= 4'b0111;
         row_val              <=4'hf;
         end
      KEY_PRESSED :                     // �а�������
      begin
        col_val          <= col;        // ������ֵ
        row_val          <= row;        // ������ֵ
        key_pressed_flag <= 1;          // �ü��̰��±�־  
      end
    endcase
//--------------------------------------
// ״̬������ ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ɨ������ֵ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
always @ (posedge key_clk, negedge rst)
  if (!rst)
  begin
    keyboard_val = 2'b0;
    number=0;
    cantopay=2;
    ensure=0;
    intoincomedisplay=0;
  end
  else
    if (key_pressed_flag)
    begin
      case ({col_val, row_val})
        8'b1110_1110 : 
        begin
        keyboard_val = 2'b01;
        number=2'b01;
        intoincomedisplay=0;
        end
        8'b1110_0111 :
        begin
          keyboard_val=0;
          number=0; 
          intoincomedisplay=0;
        end
        8'b1101_1110 : 
        begin
        keyboard_val = 2'b10;
        number=2'b10;
        intoincomedisplay=0;
        end
        8'b1011_1110 : 
        begin
        keyboard_val = 2'b11;
        number=2'b11;
        intoincomedisplay=0;
        end
        8'b0111_1110:
        begin
          intoincomedisplay=1;
        end
        8'b1011_0111 :
        begin
          if(precount>=1)
          begin
            ensure=1;
            cantopay=1;
          end
          else if(precount==0)
          begin
            ensure=0;
            cantopay=0;
          end
        end
        
        //8'b0111_1110 : keyboard_val <= 4'b1010; 
        //8'b0111_1101 : keyboard_val <= 4'b1011;
        //8'b0111_1011 : keyboard_val <= 4'b1100;
        //8'b0111_0111 : keyboard_val <= 4'b1101;  
        default:
        begin
          keyboard_val=2'b00;
          // number=2'b00;
          ensure=0;
          intoincomedisplay=0;
         // back<=0; number==0����������
        end
      endcase
      lastnumber=number;
    end
    else
    begin
        keyboard_val=2'b00;
        ensure<=0;//ensureһֱΪ1�����븶��ʱ
    end

//--------------------------------------
//  ɨ������ֵ���� ����
//--------------------------------------
      
endmodule
