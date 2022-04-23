`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	input Player1,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output q_Init, q_Wait1press, q_Wait1release, q_Wait2press, q_Wait2release, q_Win, q_Draw
   );
	reg [9:0] MID_X, MID_Y;
	reg [3:0] pointer;
	reg [3:0] moves;
	reg [8:0] fstore;
	reg [8:0] sstore;
	wire WIN1, WIN2, DRAW;
	reg [6:0] state;
	assign {q_Draw, q_Win, q_Wait2release, q_Wait2press, q_Wait1release, q_Wait1press, q_Init} = state;

	localparam
	    QINIT         = 7'b0000001,
	    QWAIT1PRESS   = 7'b0000010,
		QWAIT1RELEASE = 7'b0000100,
	    QWAIT2PRESS   = 7'b0001000,
		QWAIT2RELEASE = 7'b0010000,
	    QWIN          = 7'b0100000,
	    QDRAW         = 7'b1000000,
	    UNK           = 7'bXXXXXXX;

	wire block_fill_1, block_fill_2, block_fill_3, block_fill_4, block_fill_5, block_fill_6, block_fill_7, block_fill_8, block_fill_9,block_move;

	parameter RED        = 12'b1111_0000_0000;
	parameter BLACK      = 12'b0000_0000_0000;
	parameter WHITE      = 12'b1111_1111_1111;
	parameter RICE       = 12'b1110_1110_1100;
	parameter BACKGROUND = 12'b1111_1111_1111;
	parameter GREEN      = 12'b0000_1111_0000;
	parameter COFFEE     = 12'b0111_0101_0011;
	parameter WOOD       = 12'b1101_1010_1000;
	parameter CENTER_X   = 463;
	parameter CENTER_Y   = 275;


	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*)
		begin
			if(~bright ) //force black if not inside the display area
				rgb = BLACK;
			else if(crosshair)
				rgb = RED;
			else if( player1_0 || player1_1 || player1_2 || player1_3 || player1_4 || player1_5 || player1_6 || player1_7 || player1_8 )
				rgb = BLACK;
			else if( player2_0 || player2_1 || player2_2 || player2_3 || player2_4 || player2_5 || player2_6 || player2_7 || player2_8 )
				rgb = BLACK;
			else if (block_fill_0||block_fill_2||block_fill_4||block_fill_6||block_fill_8)
				rgb = COFFEE;
			else if (block_fill_1||block_fill_3||block_fill_5||block_fill_7)
				rgb = WOOD;
			else
				rgb = BACKGROUND;
		end

	always@(posedge clk, posedge rst)
	begin
		if(rst)
			begin
				state<=QINIT;
			end
		else
		 	begin
				case(state)
				
					QINIT:
							begin
								fstore<=9'b000000000;
								sstore<=9'b000000000;
								pointer<=4;
								MID_X<=463;
								MID_Y<=275;
								moves<=0;
								if(Player1==1)
									begin
										state<=QWAIT1RELEASE;
									end
								else
									begin
										state<=QWAIT2RELEASE;
									end
							end
							QWAIT1PRESS:
							begin
								if(right==0 && left==0 && up==0 && down==0)
									begin
										state<=QWAIT1RELEASE;

									end
							end
							QWAIT1RELEASE:
								begin
									if(right)
										begin
											state<=QWAIT1PRESS;
											if (pointer==2)
												begin
													pointer<=0;
													MID_X <= MID_X-2*105;
												end
											else if (pointer==5)
												begin
													pointer<=3;
													MID_X <= MID_X-2*105;
												end
											else if (pointer==8)
												begin
													pointer<=6;
													MID_X <= MID_X-2*105;
												end
											else
												begin
													pointer<=pointer+1;
													MID_X <= MID_X+105;
												end
										end
									else if(left)
										begin
											state<=QWAIT1PRESS;
											if (pointer==0)
												begin
													pointer<=2;
													MID_X<=MID_X+2*105;
												end
											else if (pointer==3)
												begin
													pointer<=5;
													MID_X<=MID_X+2*105;
												end
											else if (pointer==6)
												begin
													pointer<=8;
													MID_X<=MID_X+2*105;
												end
											else
												begin
													pointer<=pointer-1;
													MID_X<=MID_X - 105;
												end
										end
									else if(down)
										begin
											state<=QWAIT1PRESS;
											if (pointer==0)
												begin
													pointer<=6;
													MID_Y<=MID_Y-2*105;
												end
											else if (pointer==1)
												begin
													pointer<=7;
													MID_Y<=MID_Y-2*105;
												end
											else if (pointer==2)
												begin
													pointer<=8;
													MID_Y<=MID_Y-2*105;
												end
											else
												begin
													pointer<=pointer-3;
													MID_Y<=MID_Y+105;
												end
										end
									else if(up)
										begin
											state<=QWAIT1PRESS;
											if (pointer==6)
												begin
													pointer<=0;
													MID_Y<=MID_Y+2*105;
												end
											else if (pointer==7)
												begin
													pointer<=1;
													MID_Y<=MID_Y+2*105;
												end
											else if (pointer==8)
												begin
													pointer<=2;
													MID_Y<=MID_Y+2*105;
												end
											else
												begin
													pointer<=pointer+3;
													MID_Y<=MID_Y-105;
												end
										end
									if(DRAW)
										begin
											state<=QDRAW;
										end
									else if(WIN1||WIN2)
										begin
											state<=QWIN;
										end
									else
										begin
											if(Player1==0 && fstore[pointer]==0 && sstore[pointer]==0)
											 begin
												state<=QWAIT2RELEASE;
												fstore[pointer]<=1;
												moves<=moves+1;
											 end
										end
								end
							QWAIT2PRESS:
							begin
								if(right==0 && left==0 && up==0 && down==0)
									begin
										state<=QWAIT2RELEASE;
									end
							end
							QWAIT2RELEASE:
								begin
									if(right)
										begin
											state<=QWAIT2PRESS;
											if (pointer==2)
												begin
													pointer<=0;
													MID_X <= MID_X-2*105;
												end
											else if (pointer==5)
												begin
													pointer<=3;
													MID_X <= MID_X-2*105;
												end
											else if (pointer==8)
												begin
													pointer<=6;
													MID_X <= MID_X-2*105;
												end
											else
												begin
													pointer<=pointer+1;
													MID_X <= MID_X + 105;
												end
										end
									else if(left)
										begin
											state<=QWAIT2PRESS;
											if (pointer==0)
												begin
													pointer<=2;
													MID_X<=MID_X+2*105;
												end
											else if (pointer==3)
												begin
													pointer<=5;
													MID_X<=MID_X+2*105;
												end
											else if (pointer==6)
												begin
													pointer<=8;
													MID_X<=MID_X+2*105;
												end
											else
												begin
													pointer<=pointer-1;
													MID_X<=MID_X - 105;
												end
										end
									else if(down)
										begin
											state<=QWAIT2PRESS;
											if (pointer==0)
												begin
													pointer<=6;
													MID_Y<=MID_Y-2*105;
												end
											else if (pointer==1)
												begin
													pointer<=7;
													MID_Y<=MID_Y-2*105;
												end
											else if (pointer==2)
												begin
													pointer<=8;
													MID_Y<=MID_Y-2*105;
												end
											else
												begin
													pointer<=pointer-3;
													MID_Y<=MID_Y+105;
												end
										end
									else if(up)
										begin
											state<=QWAIT2PRESS;
											if (pointer==6)
												begin
													pointer<=0;
													MID_Y<=MID_Y+2*105;
												end
											else if (pointer==7)
												begin
													pointer<=1;
													MID_Y<=MID_Y+2*105;
												end
											else if (pointer==8)
												begin
													pointer<=2;
													MID_Y<=MID_Y+2*105;
												end
											else
												begin
													pointer<=pointer+3;
													MID_Y<=MID_Y-105;
												end
										end
									if(DRAW)
										begin
											state<=QDRAW;
										end
									else if(WIN1||WIN2)
										begin
											state<=QWIN;
										end
									else
										begin
											if(Player1==1 && fstore[pointer]==0 && sstore[pointer]==0)
												begin
													state<=QWAIT1RELEASE;
													sstore[pointer]<=1;
													moves<=moves+1;
												end
										end
								end
							QWIN:
								begin
									if(rst)
										begin
											state<=QINIT;
										end
								end
							QDRAW:
								begin
									if(rst)
										begin
											state<=QINIT;
										end
								end
							default:
								state <= UNK;
						
						endcase
			end
	   end

	assign block_fill_0 = (hCount>=(CENTER_X-155) && hCount<=(CENTER_X-55)  && vCount>=(CENTER_Y+55)  && vCount<=(CENTER_Y+155));
	assign block_fill_1 = (hCount>=(CENTER_X-50)  && hCount<=(CENTER_X+50)  && vCount>=(CENTER_Y+55)  && vCount<=(CENTER_Y+155));
	assign block_fill_2 = (hCount>=(CENTER_X+55)  && hCount<=(CENTER_X+155) && vCount>=(CENTER_Y+55)  && vCount<=(CENTER_Y+155));
	assign block_fill_3 = (hCount>=(CENTER_X-155) && hCount<=(CENTER_X-55)  && vCount>=(CENTER_Y-50)  && vCount<=(CENTER_Y+50));
	assign block_fill_4 = (hCount>=(CENTER_X-50)  && hCount<=(CENTER_X+50)  && vCount>=(CENTER_Y-50)  && vCount<=(CENTER_Y+50));
	assign block_fill_5 = (hCount>=(CENTER_X+55)  && hCount<=(CENTER_X+155) && vCount>=(CENTER_Y-50)  && vCount<=(CENTER_Y+50));
	assign block_fill_6 = (hCount>=(CENTER_X-155) && hCount<=(CENTER_X-55)  && vCount>=(CENTER_Y-155) && vCount<=(CENTER_Y-55));
	assign block_fill_7 = (hCount>=(CENTER_X-50)  && hCount<=(CENTER_X+50)  && vCount>=(CENTER_Y-155) && vCount<=(CENTER_Y-55));
	assign block_fill_8 = (hCount>=(CENTER_X+55)  && hCount<=(CENTER_X+155) && vCount>=(CENTER_Y-155) && vCount<=(CENTER_Y-55));
	
	//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	//assign block_move =(vCount>=(MID_Y-50) && vCount<=(MID_Y+50) && hCount>=(MID_X-50) && hCount<=(MID_X+50));
	assign crosshair = ((vCount>=(MID_Y-25) && vCount<=(MID_Y+25) && hCount>=(MID_X-5) && hCount<=(MID_X+5))
					||(vCount>=(MID_Y-5) && vCount<=(MID_Y+5) && hCount>=(MID_X-25) && hCount<=(MID_X-5))
					||(vCount>=(MID_Y-5) && vCount<=(MID_Y+5) && hCount>=(MID_X+5) && hCount<=(MID_X+25)));

	assign player1_0 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-105))**2<=(50**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-105))**2>=(40**2) && fstore[0]);				
	assign player1_1 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-000))**2<=(50**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-000))**2>=(40**2) && fstore[1]);
	assign player1_2 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X+105))**2<=(50**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X+105))**2>=(40**2) && fstore[2]);				
	assign player1_3 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-105))**2<=(50**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-105))**2>=(40**2) && fstore[3]);
	assign player1_4 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-000))**2<=(50**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-000))**2>=(40**2) && fstore[4]);				
	assign player1_5 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X+105))**2<=(50**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X+105))**2>=(40**2) && fstore[5]);
	assign player1_6 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-105))**2<=(50**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-105))**2>=(40**2) && fstore[6]);				
	assign player1_7 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-000))**2<=(50**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-000))**2>=(40**2) && fstore[7]);
	assign player1_8 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X+105))**2<=(50**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X+105))**2>=(40**2) && fstore[8]);	

	/*
	assign player2_0 =(((hCount-(CENTER_X-105+4))*(-4) + (vCount-(CENTER_Y+105-4))*(+4) >=0 
					 && (hCount-(CENTER_X-105-4))*(+4) + (vCount-(CENTER_Y+105+4))*(-4) >=0
					 && (hCount-(CENTER_X-105+30))*(-30) + (vCount-(CENTER_Y+105+30))*(-30) >=0
					 && (hCount-(CENTER_X-105-30))*(+30) + (vCount-(CENTER_Y+105-30))*(+30) >=0)

				);
	*/
	
	assign player1_0 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-105))**2<=(30**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-105))**2>=(20**2) && fstore[0]);	
	assign player2_1 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-000))**2<=(30**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X-000))**2>=(20**2) && sstore[1]);
	assign player2_2 =((vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X+105))**2<=(30**2) && (vCount-(CENTER_Y+105))**2 +(hCount-(CENTER_X+105))**2>=(20**2) && sstore[2]);				
	assign player2_3 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-105))**2<=(30**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-105))**2>=(20**2) && sstore[3]);
	assign player2_4 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-000))**2<=(30**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X-000))**2>=(20**2) && sstore[4]);				
	assign player2_5 =((vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X+105))**2<=(30**2) && (vCount-(CENTER_Y+000))**2 +(hCount-(CENTER_X+105))**2>=(20**2) && sstore[5]);
	assign player2_6 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-105))**2<=(30**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-105))**2>=(20**2) && sstore[6]);				
	assign player2_7 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-000))**2<=(30**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X-000))**2>=(20**2) && sstore[7]);
	assign player2_8 =((vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X+105))**2<=(30**2) && (vCount-(CENTER_Y-105))**2 +(hCount-(CENTER_X+105))**2>=(20**2) && sstore[8]);					

	assign WIN1=fstore[0]*fstore[1]*fstore[2]+fstore[3]*fstore[4]*fstore[5]+fstore[6]*fstore[7]*fstore[8]+
				fstore[0]*fstore[3]*fstore[6]+fstore[1]*fstore[4]*fstore[7]+fstore[2]*fstore[5]*fstore[8]+
				fstore[0]*fstore[4]*fstore[8]+fstore[2]*fstore[4]*fstore[6];

	assign WIN2=sstore[0]*sstore[1]*sstore[2]+sstore[3]*sstore[4]*sstore[5]+sstore[6]*sstore[7]*sstore[8]+
				sstore[0]*sstore[3]*sstore[6]+sstore[1]*sstore[4]*sstore[7]+sstore[2]*sstore[5]*sstore[8]+
				sstore[0]*sstore[4]*sstore[8]+sstore[2]*sstore[4]*sstore[6];

	assign DRAW= ~WIN2 && ~WIN1 && (moves==9);

	
	
endmodule
