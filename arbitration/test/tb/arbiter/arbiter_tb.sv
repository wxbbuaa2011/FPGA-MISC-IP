///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Testbench for arbiter
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module arbiter_tb;

    // Parameters
    localparam  WIDTH = 4;

    // Ports
    reg [WIDTH-1:0] req;
    reg [WIDTH-1:0] base;
    wire [WIDTH-1:0] grant;

    arbiter
        #(
            .WIDTH (
                WIDTH )
        )
        arbiter_dut (
            .req (req ),
            .base (base ),
            .grant  ( grant)
        );

    integer error = 0;

    initial begin
        test('b0001, 'b0010, 'b0001);
        test('b0011, 'b0010, 'b0010);
        test('b0111, 'b0010, 'b0010);
        test('b1111, 'b0010, 'b0010);
        test('b1111, 'b0100, 'b0100);
        test('b1111, 'b1000, 'b1000);
        test('b0000, 'b0010, 'b0000);
        if (error == 0) $display("TEST PASSED!");
        else $display("TEST FAILED");
        $finish;
    end


    task  automatic test;
        input [WIDTH-1:0] req_in;
        input [WIDTH-1:0] base_in;
        input [WIDTH-1:0] expected;
        begin
            #1;
            req = req_in;
            base = base_in;
            #1;
            assert(grant == expected) else error = error + 1;
        end
    endtask

endmodule
