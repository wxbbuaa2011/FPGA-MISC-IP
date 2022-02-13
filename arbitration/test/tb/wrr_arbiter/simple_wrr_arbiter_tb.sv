///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Testbench for wrr_arbiter
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module simple_wrr_arbiter_tb;

    // Parameters
    localparam  WIDTH = 4;
    localparam  CWIDTH = 2;

    // Ports
    reg clk = 0;
    reg rst = 0;
    reg [WIDTH-1:0] req = 0;
    reg [WIDTH-1:0] base;
    reg [WIDTH*CWIDTH-1:0] weights = {2'd2, 2'd1, 2'd3, 2'd3};
    wire [WIDTH-1:0] grant;


    wrr_arbiter
        #(.WIDTH (WIDTH))
    wrr_arbiter_dut (
        .clk (clk ),
        .rst (rst ),
        .req (req ),
        .weights (weights ),
        .grant  (grant )
    );

    integer error = 0;

    always #5  clk = ! clk ;

    initial
    begin
        rst = 1'b1;
        repeat(3) @(negedge clk);
        rst = 1'b0;
        test('b1111, 'b0001);
        test('b1111, 'b0001);
        test('b1111, 'b0001);
        test('b1111, 'b0010);
        test('b1111, 'b0010);
        test('b1111, 'b0010);
        test('b1111, 'b0100);
        test('b1111, 'b1000);
        test('b1111, 'b1000); // credit reset
        test('b1111, 'b0001);
        test('b1100, 'b0100); // credit reset
        test('b1100, 'b1000);
        test('b0100, 'b0100); // credit reset
        @(posedge clk);
        if (error == 0)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED");
        $finish;
    end


    task test;
        input [WIDTH-1:0] req_in;
        input [WIDTH-1:0] expected;
        begin
            @(posedge clk);
            #1 req = req_in;
            #1 assert(grant == expected) else error = error + 1;
        end
    endtask

    initial begin
        $dumpfile("simple_wrr_arbiter_tb.vcd");
        $dumpvars(0,simple_wrr_arbiter_tb);
    end

endmodule
