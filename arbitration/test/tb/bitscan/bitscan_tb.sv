///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Testbench for bitscan
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module bitscan_tb ();

    parameter WIDTH = 8;

    wire [WIDTH-1:0]    grant;
    reg [WIDTH-1:0]     req;

    bitscan #(.WIDTH(WIDTH)) DUT(.*);

    integer error = 0;

    task automatic test;
        input [WIDTH-1:0] test_in;
        input [WIDTH-1:0] expected;
        begin
            #1 req = test_in;
            #1 assert(grant == expected) else error = error + 1;
        end
    endtask

    initial begin
        test('b00000001, 'b00000001);
        test('b00000111, 'b00000001);
        test('b00000101, 'b00000001);
        test('b00000100, 'b00000100);
        test('b00011100, 'b00000100);
        test('b00010100, 'b00000100);
        test('b10000000, 'b10000000);
        test('b00000000, 'b00000000);
        if (error == 0) $display("TEST PASSED!");
        else $display("TEST FAILED");
    end

    initial begin
        $dumpfile("bitscan.vcd");
        $dumpvars(0,bitscan_tb);
    end

endmodule