`timescale 1ns / 1ps

module tx_top(
    input wire logic            clk, 
    input wire logic            btnu, 
    input wire logic    [7:0]   sw, 
    input wire logic            btnc, 
    output logic        [3:0]   anode, 
    output logic        [7:0]   segment, 
    output logic                tx_out, 
    output logic                tx_debug);

    logic reset;
    assign reset = btnu;
    assign tx_debug = tx_out;

    logic   btnc_r;
    logic   btnc_r2;
    logic   send_character;
    
    // Button synchronizaer
    always_ff@(posedge clk)
    begin
       btnc_r <= btnc;
       btnc_r2 <= btnc_r;
    end

    // Debounce the start button
    debounce debounce_inst(
        .clk(clk),
        .reset(reset),
        .noisy(btnc_r2),
        .debounced(send_character)
    );
    
    // Transmitter
    tx tx_inst(
        .clk    (clk), 
        .Reset  (reset),
        .Send   (send_character),
        .Din    (sw),
        .Sent   (),
        .Sout   (tx_out)
    );
        
    // Seven Segment Display
    SevenSegmentControl SSC (
        .clk(clk),
        .reset(reset),
        .dataIn({8'h00, sw}),
        .digitDisplay(4'h3),
        .digitPoint(4'h0), 
        .anode(anode),
        .segment(segment)
    );

    
endmodule