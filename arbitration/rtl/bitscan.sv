///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// Simple fixed priority arbitration. The lowerst request get the grant
//
//
// Example:
// input:  'b101010100100
// output: 'b000000000100
//
// Reference: <Altera Advanced Synthesis Cookbook>
//
///////////////////////////////////////////////////////////////////////////////

module bitscan #(
    parameter WIDTH = 16
) (
    input [WIDTH-1:0]       req,
    output [WIDTH-1:0]      grant
);

    assign grant = req & (~req+1);

endmodule


// algorithm:
//  req:              1010
//  ~req+1:           0101 + 1 => 0110
//  req & (~req+1):    1010 & 0110 => 0010
