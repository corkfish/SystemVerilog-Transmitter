`timescale 1ns / 1ps

`default_nettype none

module tx(
        input wire logic clk, Reset, Send,
        input wire logic [7:0] Din,
        output logic Sent, Sout);
        
        logic timerDone, clrTimer, startBit, dataBit, parityBit, incBit, clrBit, bitDone;
        logic [2:0] bitNum;
        logic [13:0] Q;
        
        typedef enum logic [2:0] {IDLE, START, BITS, PAR, STOP, ACK, ERR='X} stateType;
        stateType ns, cs;
        
        always_ff @ (posedge clk)
            if(Reset || clrTimer)
                Q <= 0;
            else if(Q == 5208 && ~Reset)
                    Q <= 0;
            else
                Q <= Q + 1;
                
       assign timerDone = (Q == 5208 && ~Reset) ? 1'b1 : 1'b0; 
       
       always_ff @ (posedge clk)
            if(clrBit)
                bitNum <= 0;
            else if(incBit)
                bitNum <= bitNum + 1;
                
                
       assign bitDone = (bitNum == 7) ? 1'b1 : 1'b0;
                
       always_ff @ (posedge clk)
            if(startBit)
                Sout <= 0;
            else if(dataBit)
                Sout <= Din[bitNum];
            else if(parityBit)
                Sout <= ~^Din;
            else
                Sout <= 1;
                
       always_comb
        begin
            ns = ERR;
            clrTimer = 0;
            startBit = 0;
            dataBit = 0;
            clrBit = 0;
            incBit = 0;
            parityBit = 0;
            Sent = 0;
            
            if(Reset)
                ns = IDLE;
            else
                case(cs)
                    IDLE: begin
                            clrTimer = 1;
                            if(Send)
                                ns = START;
                            else
                                ns = IDLE;
                          end
                   START: begin
                            startBit = 1;
                            if(timerDone)
                                begin
                                    clrBit = 1;
                                    ns = BITS;
                                end
                            else
                                ns = START;
                          end
                   BITS: begin
                            dataBit = 1;
                            if(timerDone && bitDone)
                                ns = PAR;
                            else if(timerDone && ~bitDone)
                                begin
                                    incBit = 1;
                                    ns = BITS;
                                end
                            else
                                ns = BITS;
                         end
                   PAR: begin
                            parityBit = 1;
                            if(timerDone)
                                ns = STOP;
                            else
                                ns = PAR;
                        end
                   STOP: if(timerDone)
                            ns = ACK;
                         else
                            ns = STOP;
                   ACK: begin
                            Sent = 1;
                            if(Send)
                                ns = ACK;
                            else
                                ns = IDLE;
                        end
                endcase
        end
            
        always_ff @ (posedge clk)
            cs <= ns;
endmodule