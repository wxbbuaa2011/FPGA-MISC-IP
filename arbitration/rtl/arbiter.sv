///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Arbiter with fair priority (fixed priority aribter)
//
// Reference: <Altera Advanced Synthesis Cookbook>
//
///////////////////////////////////////////////////////////////////////////////

module arbiter #(
    parameter WIDTH = 16
) (
    input [WIDTH-1:0]       req,
    input [WIDTH-1:0]       base,   // the base is a one-hot encoding indicating the request that has highest priority
    output [WIDTH-1:0]      grant
);

    wire [WIDTH*2-1:0] double_req;
    wire [WIDTH*2-1:0] double_grant;

    assign double_req = {req, req};
    assign double_grant = double_req & (~double_req + {{WIDTH{1'b0}}, base});
    assign grant = double_grant[WIDTH-1:0] | double_grant[WIDTH*2-1:WIDTH];

endmodule

// Algorithm:
//
// The principle is almost the same as bitscan.
// The base divides the req into 2 parts. The one in the left part has higher priority then the right part
// By doubling the request, we are "moving" the right part to the left most so its priority is lowered.
// Then we use bitscan to get the grant and adjust the grant to the correct position
