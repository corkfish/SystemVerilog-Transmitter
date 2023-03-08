`timescale 1ns / 1ps

`default_nettype none
module debounce(
 input wire logic clk, reset, noisy,
 output logic debounced);

 logic timerDone, clrTimer;
 logic [18:0] useless;

 typedef enum logic [1:0] {s0, s1, s2, s3, ERR='X} stateType;
 stateType ns, cs;

 always_comb
 begin
 ns = ERR;
 clrTimer = 0;
 debounced = 0;

 if(reset)
 begin
 ns = s0;
 clrTimer = 1;
 end
 else
 case(cs)
 s0: begin
 clrTimer = 1;
 if(noisy)
 ns = s1;
 else
 ns = s0;
 end
 s1: if(noisy && timerDone)
 ns = s2;
 else if(noisy && ~timerDone)
 ns = s1;
 else
 ns = s0;
 s2: begin
 debounced = 1;
 clrTimer = 1;
 if(~noisy)
 ns = s3;
 else
 ns = s2;
 end
 s3: begin
 debounced = 1;
 if(~noisy && timerDone)
 ns = s0;
 else if(~noisy && ~timerDone)
 ns = s3;
 else
 ns = s2;
 end
 endcase
 end

 always_ff@(posedge clk)
 cs <= ns;

 mod_counter #(500001, 19) counter(.clk(clk), .reset(clrTimer),
.increment(1'b1), .rolling_over(timerDone), .count(useless));

endmodule