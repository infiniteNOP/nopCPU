/* 
 * ALU for simple 8-bit CPU.
 * Copyright (C) 2015, 16 John Tzonevrakis.
 * Licensed under the LGPL license. For more details, read the COPYING file.
 *
*/

module alu  (input [7:0] a,b,
             input [3:0] opcode,
             output reg [7:0] y);
    reg [7:0] o, an, n, x, add, sub, rsn;
    /* Decode the instruction */
    always @* begin
        o <= a | b;
        an <= a & b;
        n <= ~a;
        x <= a ^ b;
        add <= a + b;
        sub <= a - b;
        rsn <= a >> b;
        case (opcode)
            4'h0 /* OR */:   y <= o;
            4'h1 /* AND */:   y <= an;
            4'h2 /* NOTA */:   y <= n;
            4'h3 /* XOR */:   y <= x;
            4'h4 /* ADD */:   y <= add;
            4'h5 /* SUB */:   y <= sub;
            4'h6 /* TX */: y <= b;
            4'h7 /* RSHIFTN */: y <= rsn;
            default: y <= 8'bZ;
        endcase
    end
endmodule //alu
