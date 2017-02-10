/* 
 * Register file for simple 8-bit CPU.
 * Copyright (C) 2015, 16 John Tzonevrakis.
 * Licensed under the LGPL license. For more details, read the COPYING file.
 *
*/

module regfile (input [1:0] readreg1, readreg2, writereg,
                input [7:0] data,
                input clk, regwrite,
                output [7:0] read1, read2);
    reg [7:0] registerfile [3:0];
    initial begin
        registerfile[2'd0] <= 8'b0;
        registerfile[2'd1] <= 8'b0;
        registerfile[2'd2] <= 8'b0;
        registerfile[2'd3] <= 8'b0;
    end 
    always @(posedge clk) begin
        if(regwrite == 1)
            registerfile[writereg] <= data;
    end
    
    assign read1 = (regwrite && readreg1 == writereg)? data: registerfile[readreg1];
    assign read2 = (regwrite && readreg2 == writereg)? data: registerfile[readreg2];
endmodule //regfile
