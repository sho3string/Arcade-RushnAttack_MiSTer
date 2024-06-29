/*******************************************************
   FPGA Implimentation of "Green Beret" (Top Module)
********************************************************/
// Copyright (c) 2013,19 MiSTer-X

module greenberet
(
	input				clk48M,
	input				reset,

	input	  [5:0]	INP0,			// Control Panel
	input	  [5:0]	INP1,
	input	  [3:0]	INP2,

	input	  [7:0]	DSW0,			// DipSWs
	input	  [7:0]	DSW1,
	input	  [7:0]	DSW2,
	
	
	input   [8:0]  PH,         // PIXEL H
	input   [8:0]  PV,         // PIXEL V
	output         PCLK,       // PIXEL CLOCK (to VGA encoder)
	output [11:0]	POUT, 	   // PIXEL OUT

	output  [7:0]	SND,			// Sound Out


	input				ROMCL,		// Downloaded ROM image
	input  [17:0]  ROMAD,
	input   [7:0]	ROMDT,
	input				ROMEN,

	input   [7:0]  title,
	input				pause,

	input	 [15:0]	hs_address,
	input	 [7:0]	hs_data_in,
	output [7:0]	hs_data_out,
	input				hs_write,
	input				hs_access
);

// Clocks
wire clk24M, clk12M, clk6M, clk3M;
CLKGEN clks( clk48M, pause, clk24M, clk12M, clk6M, clk3M );

wire   VCLKx8 = clk48M;
wire   VCLKx4 = clk24M;
wire   VCLKx2 = clk12M;
wire   VCLK = clk6M;

wire   CPUCLK = clk3M;
wire   CPUCL = ~clk3M;


// Main
wire			CPUMX, CPUWR, VIDDV;
wire  [7:0]	CPUWD, VIDRD;
wire [15:0]	CPUAD;


MAIN cpu
(
	CPUCLK, reset,
	PH,PV,
	INP0,INP1,INP2,
	DSW0,DSW1,DSW2,
	
	CPUMX, CPUAD,
	CPUWR, CPUWD,
	VIDDV, VIDRD,
	
	ROMCL,ROMAD,ROMDT,ROMEN,

	title,
	pause
);


// Video
VIDEO vid
(
	VCLKx8, VCLKx4, VCLKx2, VCLK,
	PH, PV, 1'b0, 1'b0,
	PCLK, POUT,

	CPUCL,
	CPUMX, CPUAD,
	CPUWR, CPUWD,
	VIDDV, VIDRD,

	ROMCL,ROMAD,ROMDT,ROMEN,

	hs_address,hs_data_in,hs_data_out,hs_write,hs_access
);


// Sound
SOUND snd
(
	clk48M, reset,
	SND,

	CPUCL,
	CPUMX, CPUAD,
	CPUWR, CPUWD,

	pause
);

endmodule


//----------------------------------
//  Clock Generator
//----------------------------------
module CLKGEN
(
	input   clk48M,
	input	pause,

	output	clk24M,
	output	clk12M,
	output	clk6M,
	output	clk3M
);

reg [3:0] clkdiv;
always @( posedge clk48M )
begin
	clkdiv <= clkdiv+4'd1;
end

assign clk24M = clkdiv[0];
assign clk12M = clkdiv[1];
assign clk6M  = clkdiv[2];
assign clk3M  = clkdiv[3];

endmodule


