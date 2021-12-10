//FSM
module ahb_slave(
	input hclk,
	input hreset_n,
	input hselx,
	input [31:0] haddr,
	input hwrite,
	input [1:0] htrans,//transfer type:nonseq,seq,idle,busy
	input [2:0] hsize,//length of data per cyclye
	input [2:0] hburst,//burst type:single,incr,wrap
	input [31:0] hwdata,
	output reg hready,
	output [1:0] hresp,//transfer response:okay,error,retry,split
	output reg [31:0] hrdata);
reg hready1;
reg hready2;
reg hready3;
reg hready4;//registers to count incr/wrap beats

wire [7:0] addr1= haddr[7:0];

reg [7:0] hrdata1;
reg [7:0] hrdata2;
reg [7:0] hrdata3;
reg [7:0] hrdata4;//save data read from data zone,split by 8-bit

parameter idle = 2'b00;
parameter busy = 2'b01;
parameter nonseq = 2'b10;
parameter seq = 2'b11;//transition type encoding

parameter bits8 = 3'b000;
parameter bits16 = 3'b001;
parameter bits32 = 3'b010;
parameter bits64 = 3'b011;
parameter bits128 = 3'b100;
parameter bits256 = 3'b101;
parameter bits512 = 3'b110;
parameter bits1024 = 3'b111;//data size encoding

parameter single=3'b000;
parameter incr=3'b001;
parameter wrap4=3'b010;
parameter incr4=3'b011;
parameter wrap8=3'b100;
parameter incr8=3'b101;
parameter wrap16=3'b110;
parameter incr16=3'b111;//burst type encoding

parameter okay=2'b00;
parameter error=2'b01;
parameter retry=2'b10;
parameter split=2'b11;//response type encoding

reg [31:0] data [255:0];//simulate data zone,move outside
integer i;
//read and write


always@(posedge hclk or negedge hreset_n)
begin
	if(!hreset_n)
	begin
		for(i=0;i<=255;i=i+1)
		begin
			data[i]<=0;
		end
		hready<=1'b0;
		hrdata<=32'b0;
		hrdata1<=8'h0;
		hrdata2<=8'h0;
		hrdata3<=8'h0;
		hrdata4<=8'h0;
	end
	else 
	begin
		case(hburst)
		single:
		begin
			if(!hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1'b1;
				hready1<=hready;
				if(hready1==1)
				begin
					hrdata<={hrdata4,hrdata3,hrdata2,hrdata1};
					case(hsize)
					bits8:
					begin
						hrdata1<=data[addr1];
					end
					bits16:
					begin
						hrdata1<=data[addr1];
						hrdata2<=data[addr1+1];
							
					end
					bits32:
					begin
						hrdata1<=data[addr1];
						hrdata2<=data[addr1+1];
						hrdata3<=data[addr1+2];
						hrdata4<=data[addr1+3];
					end
					endcase
				end
			end
			else if(hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1'b1;
				hready1<=hready;
				if(hready1==1)
				begin
					case(hsize)
					bits8:
					begin
						data[addr1]<=hwdata[7:0];
					end
					bits16:
					begin
						data[addr1]<=hwdata[7:0];
						data[addr1+1]<=hwdata[15:8];
					end
					bits32:
					begin
						data[addr1]<=hwdata[7:0];
						data[addr1+1]<=hwdata[15:8];
						data[addr1+2]<=hwdata[23:16];
						data[addr1+3]<=hwdata[31:24];
					end
					endcase
				end
			end
		end
		incr4:
		begin
			if(!hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1;
				hready1<=hready;
				hready2<=hready1;
				hready3<=hready2;
				hready4<=hready3;
				case(hsize)
					bits32:
					begin
						if(hready1==1)
							hrdata<=data[addr1];
						else if(hready2==1)
							hrdata<=data[addr1+4];
						else if(hready3==1)
							hrdata<=data[addr1+8];
						else if(hready4==1)
							hrdata<=data[addr1+12];
					end
				endcase
			end
			else if(hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1;
				hready1<=hready;
				hready2<=hready1;
				hready3<=hready2;
				hready4<=hready3;
				case(hsize)
					bits32:
					begin
						if(hready1==1)
							data[addr1]<=hwdata;
						else if(hready2==1)
							data[addr1+4]<=hwdata;
						else if(hready3==1)
							data[addr1+8]<=hwdata;
						else if(hready4==1)
							data[addr1+12]<=hwdata;
					end
				endcase
			end
		end
		wrap4:
		begin
			if(!hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1;
				hready1<=hready;
				hready2<=hready1;
				hready3<=hready2;
				hready4<=hready3;
				case(hsize)
				bits32:
				begin
					if(hready1==1)
					begin
					case(addr1[3:0])
					4'h0:
						begin
						if(hready1==1)
							hrdata<=data[addr1];
						else if(hready2==1)
							hrdata<=data[addr1+4];
						else if(hready3==1)
							hrdata<=data[addr1+8];
						else if(hready4==1)
							hrdata<=data[addr1+12];
						end
					4'h4:
						begin
						if(hready1==1)
							hrdata<=data[addr1];
						else if(hready2==1)
							hrdata<=data[addr1+4];
						else if(hready3==1)
							hrdata<=data[addr1+8];
						else if(hready4==1)
							hrdata<=data[addr1-4];
						end
					4'h8:
						begin					
						if(hready1==1)
							hrdata<=data[addr1];
						else if(hready2==1)
							hrdata<=data[addr1+4];
						else if(hready3==1)
							hrdata<=data[addr1-8];
						else if(hready4==1)
							hrdata<=data[addr1-4];
						end
					4'hc:
						begin
						if(hready1==1)
							hrdata<=data[addr1];
						else if(hready2==1)
							hrdata<=data[addr1-12];
						else if(hready3==1)
							hrdata<=data[addr1-8];
						else if(hready4==1)
							hrdata<=data[addr1-4];
						end
					endcase
					end
				end
				endcase
			end
			else if(hwrite&&hselx&&(htrans[1:0]==nonseq))
			begin
				hready<=1;
				hready1<=hready;
				hready2<=hready1;
				hready3<=hready2;
				hready4<=hready3;
				case(hsize)
				bits32:
				begin
					if(hready1==1)
					begin
					case(addr1[3:0])
					4'h0:
						begin
						if(hready1==1)
							data[addr1]<=hwdata;
						else if(hready2==1)
							data[addr1+4]<=hwdata;
						else if(hready3==1)
							data[addr1+8]<=hwdata;
						else if(hready4==1)
							data[addr1+12]<=hwdata;
						end
					4'h4:
						begin
						if(hready1==1)
							data[addr1]<=hwdata;
						else if(hready2==1)
							data[addr1+4]<=hwdata;
						else if(hready3==1)
							data[addr1+8]<=hwdata;
						else if(hready4==1)
							data[addr1-4]<=hwdata;
						end
					4'h8:
						begin					
						if(hready1==1)
							data[addr1]<=hwdata;
						else if(hready2==1)
							data[addr1+4]<=hwdata;
						else if(hready3==1)
							data[addr1-8]<=hwdata;
						else if(hready4==1)
							data[addr1-4]<=hwdata;
						end
					4'hc:
						begin
						if(hready1==1)
							data[addr1]<=hwdata;
						else if(hready2==1)
							data[addr1-12]<=hwdata;
						else if(hready3==1)
							data[addr1-8]<=hwdata;
						else if(hready4==1)
							data[addr1-4]<=hwdata;
						end
					endcase
					end
				end
				endcase	
			end
		end
		endcase
	end
end
endmodule

