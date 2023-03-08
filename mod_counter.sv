`timescale 1ns / 1ps

`default_nettype none
module mod_counter #(MOD_VALUE=10, WID=4)(
 input wire logic clk, reset, increment,
 output logic rolling_over,
 output logic [(WID-1):0] count);

 always_ff@(posedge clk)
 if(reset)
 count <= 0;
 else if(increment && count==(MOD_VALUE-1))
 count <= 0;
 else if(increment)
 count <= count + 1;

 assign rolling_over = (increment && count==(MOD_VALUE-1)) ? 1: 0;

endmodule