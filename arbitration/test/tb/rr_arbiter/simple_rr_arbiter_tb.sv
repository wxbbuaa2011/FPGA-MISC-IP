///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// A simple directed testbench for rr_arbiter
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module simple_rr_arbiter_tb;

    // Parameters
    localparam  WIDTH = 4;

    // Ports
    reg clk = 0;
    reg rst = 0;
    reg [WIDTH-1:0] req = 0;
    reg [WIDTH-1:0] base;
    wire [WIDTH-1:0] grant;

    rr_arbiter
        #(
            .WIDTH (
                WIDTH )
        )
        arbiter_dut (
            .clk (clk ),
            .rst (rst ),
            .req (req ),
            .grant  ( grant)
        );

    integer error = 0;

    always #5 clk = !clk ;

    initial
    begin
        rst = 1'b1;
        repeat(3) @(negedge clk);
        rst = 1'b0;
        test('b1111, 'b0001);
        test('b1110, 'b0010);
        test('b1100, 'b0100);
        test('b1000, 'b1000); // mask reset
        test('b1110, 'b0010);
        test('b1101, 'b0100);
        test('b1001, 'b1000);
        test('b0001, 'b0001); // mask reset
        test('b0011, 'b0001); // mask reset
        test('b0010, 'b0010);
        test('b0011, 'b0001);
        test('b0010, 'b0010);

        @(posedge clk);
        if (error == 0)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED");
        $finish;
    end


    task automatic test;
        input [WIDTH-1:0] req_in;
        input [WIDTH-1:0] expected;
        begin
            @(posedge clk);
            #1 req = req_in;
            #1 assert(grant == expected) else error = error + 1;
        end
    endtask

    initial begin
        $dumpfile("simple_rr_arbiter_test.vcd");
        $dumpvars(0,simple_rr_arbiter_tb);
    end

endmodule
