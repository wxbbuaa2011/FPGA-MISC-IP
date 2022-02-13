///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// weighted round robin arbiter
//
///////////////////////////////////////////////////////////////////////////////

module wrr_arbiter #(
    parameter WIDTH  = 16,
    parameter CWIDTH = 2    // credit weights
) (
    input                       clk,
    input                       rst,
    input [WIDTH*CWIDTH-1:0]    weights,
    input [WIDTH-1:0]           req,
    output [WIDTH-1:0]          grant
);

    logic                   new_round;
    logic [WIDTH-1:0]       credit_mask;
    logic [WIDTH-1:0]       req_with_credit;
    logic [WIDTH-1:0]       masked_req;

    reg [WIDTH-1:0][CWIDTH-1:0] credits;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            always @(posedge clk) begin
                if (rst) begin
                    credits[i] <= weights[CWIDTH*i+CWIDTH-1:CWIDTH*i];
                end
                else begin
                    if (new_round) begin
                        // extract 1 credit for the granted item
                        credits[i] <= weights[CWIDTH*i+CWIDTH-1:CWIDTH*i] - grant[i];
                    end
                    else begin
                        credits[i] <= credits[i] - grant[i];
                    end
                end
            end

            assign credit_mask[i] = (credits[i] != 0);   // set the credit_mask to 1 if there are credit for that grant
        end
    endgenerate

    assign req_with_credit = credit_mask & req;
    assign new_round = (req_with_credit == 0);
    assign masked_req = new_round ? req : req_with_credit;
    assign grant = masked_req & (~masked_req + 1);

endmodule

// lgorithm
// 1. When a new round start, the credit counter for all the request channel will be loaded.
// 2. Each req will decrease credit by 1.
// 3. When a request has used up all it's credit, it need to wait till the credit get reloaded in a new round
// 4. When there is no credit for all the new request, a new round will be started
