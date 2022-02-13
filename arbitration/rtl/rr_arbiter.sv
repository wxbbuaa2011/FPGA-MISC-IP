///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Round Robin Arbiter
//
// Assumption:
//  A request should remain asserted until it is granted
//  If the request is de-asserted whiling waiting for arbitration.
//  It will be arbitrated in the next available round.
//
///////////////////////////////////////////////////////////////////////////////

module rr_arbiter #(
    parameter WIDTH = 8
) (
    input                   clk,
    input                   rst,
    input [WIDTH-1:0]       req,
    output [WIDTH-1:0]      grant
);

    reg [WIDTH-1:0]     remaining_req;

    logic               new_round;
    logic [WIDTH-1:0]   remaining_req_after_grant;
    logic [WIDTH-1:0]   maksed_req;

    always @(posedge clk) begin
        if (rst) begin
            remaining_req <= 'b0;
        end
        else begin
            if (new_round) begin
                remaining_req <= req ^ grant;
            end
            else begin
                remaining_req <= remaining_req_after_grant;
            end
        end
    end

    assign remaining_req_after_grant = remaining_req ^ grant;
    assign new_round = (remaining_req & req) == 0;
    assign maksed_req = new_round ? req : remaining_req & req;
    assign grant = maksed_req & (~maksed_req + 1);


endmodule

// Algorithm:
// - Whenever a request has been granted, we mask it out so it will not be
// considered in the next turn.
// - When all the request has been granted, a new turn will be started