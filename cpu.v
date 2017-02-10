/* 
 * Datapath for simple 8-bit CPU.
 * Copyright (C) 2015, 16 John Tzonevrakis.
 * Licensed under the GPL license. For more details, read the COPYING file.
 *
*/

module cpu(input clk, reset, interrupt,
           input [7:0] datamem_data, usermem_data_in,
           output [7:0] datamem_address, usermem_address, usermem_data_out,
           output rw);
    wire [1:0] regfile_read1, regfile_read2, regfile_writereg; 
    wire [7:0] pc_jumpaddr, regfile_data, regfile_out1, regfile_out2;
    wire [7:0] alu_out;
    wire [3:0] alu_opcode;

    pc pc0(clk, reset, pc_jump, pc_jumpaddr, datamem_address);
    regfile reg0(regfile_read1, regfile_read2, regfile_writereg,
                 regfile_data, clk,  regfile_regwrite,
                 regfile_out1, regfile_out2);
    alu alu0(regfile_out1, regfile_out2, alu_opcode, alu_out);
    control cntrl0(clk, reset, interrupt, datamem_data, datamem_address, regfile_out1, regfile_out2,
                   alu_out, usermem_data_in, alu_opcode, 
                   regfile_data, usermem_data_out, regfile_read1, regfile_read2,
                   regfile_writereg, usermem_address,
                   pc_jumpaddr, rw, regfile_regwrite,
                   pc_jump); 
endmodule //cpu
