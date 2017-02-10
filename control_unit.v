/* 
* Control Unit for simple 8-bit CPU.
* Copyright (C) 2015, 16 John Tzonevrakis.
* Licensed under the LGPL license. For more details, read the COPYING file.
*
*/

module control (input clk, reset, interrupt,
                input [7:0] datamem_data, datamem_address, regfile_out1, 
                input [7:0] regfile_out2, alu_out, usermem_data_in,
                output reg [3:0] alu_opcode,
                output reg [7:0] regfile_data,usermem_data_out,
                output reg [1:0] regfile_read1, regfile_read2, regfile_writereg,
                output reg [7:0] usermem_address, pc_jmpaddr,
                output reg rw, regfile_regwrite, pc_jump);
    /* Parameters */
    parameter state0 = 3'h0;
    parameter state1 = 3'h1;
    parameter state2 = 3'h2;
    parameter state3 = 3'h3;
    /* Flags */
    reg [2:0] stage;
    reg [7:0] instruction_c;
    reg [7:0] instruction;
    reg [7:0] sp;
    reg is_onecyc, is_alu;
    reg eq;
    /* Combinational logic goes here */
    always @(*) begin
        instruction_c <= datamem_data;
        is_alu <= (instruction_c[7:4] <= 4'h7);
        is_onecyc <= (instruction_c[7:4] <= 4'hd);
        alu_opcode <= instruction_c[7:4];
        regfile_read1 <= is_onecyc ? instruction_c[3:2] : instruction[3:2];
        regfile_read2 <= is_onecyc ? instruction_c[1:0] : instruction[1:0];
        regfile_writereg <= instruction[1:0];
        eq <= (regfile_out1 == regfile_out2);
    end
    always @(posedge clk)
        if(interrupt == 1)
        begin
            pc_jump <= 1;
            pc_jmpaddr <= 8'hfd;
            stage <= state2;
        end
        /* Check for reset*/
        else if(reset == 1)
        begin
                sp <= 0;
            {instruction, regfile_data, usermem_data_out, usermem_address} <= 8'b0;
            {rw, regfile_regwrite} <= 1'b0;
            pc_jump <= 1;
            pc_jmpaddr <= 8'b0;
            stage <= state2;
        end
        /* Stage 1: Fetch instruction, execute it in case it does not require an operand: */
        else if (stage == state0)
        begin
            rw <= 0;
            instruction <= datamem_data;
            if (is_alu)
            begin
                rw <= 0;
                regfile_regwrite <= 1;
                regfile_data <= alu_out;
                stage <= state0;
            end
            else if (is_alu == 0) begin
                case (instruction_c[7:4])
                    4'h9 /* JMP/NOP */:
                    begin
                        pc_jmpaddr <= regfile_out2;
                        regfile_regwrite <= 0;
                        pc_jump <= 1;
                        stage <= state2;
                    end
                    4'ha /* CALL */:
                    begin
                        rw <= 1;
                        sp <= usermem_address;
                        usermem_address <= sp + 1;
                        usermem_data_out <= datamem_address;
                        pc_jmpaddr <= regfile_out2;
                        regfile_regwrite <= 0;
                        pc_jump <= 1;
                        stage <= state2;
                    end
                    4'hb /* RTS */:
                    begin
                        pc_jump <= 1;
                        sp <= usermem_address;
                        usermem_address <= sp -1;
                        regfile_regwrite <= 0;
                        pc_jmpaddr <= usermem_data_in;
                        stage <= state2;
                    end
                    4'hc /* IEQ */:
                    begin
                        regfile_regwrite <= 0;
                        if(eq)
                        begin
                            stage <= state3;
                        end
                        else 
                            stage <= state0;
                    end
                    4'hd /* INE */:
                    begin
                        regfile_regwrite <= 0;
                        if(eq == 0)
                        begin
                            stage <= state3;
                        end
                        else
                            stage <= state0;
                    end
                    default:  stage <= state1;
                endcase
            end
        end
        /* Stage 2: Fetch the operand and execute the relevant instruction: */
        else if (stage == state1)
        begin
            case (instruction[7:4])
                4'h8 /* LD */:
                begin
                    rw <= 0;
                    regfile_regwrite <= 1;
                    regfile_data <= datamem_data;
                    stage <= state0;
                end
                4'he /* ST */:
                begin
                    rw <= 1;
                    regfile_regwrite <= 0;
                    usermem_address <= datamem_data;
                    usermem_data_out <= regfile_out1;
                    stage <= state0;
                end
                4'hf /* LDUMEM */:
                begin
                    rw <= 0;
                    usermem_address <= datamem_data;
                    regfile_regwrite <= 1;
                    regfile_data <= usermem_data_in;
                    stage <= state0;
                end
            endcase
        end
        else if(stage == state2)
        begin
            rw <= 0;
            instruction <= datamem_data;
            pc_jump <= 0;
            stage <= state0;
        end
        else if(stage == state3)
        begin
            /* Skip an instruction */
            if(is_onecyc)
                stage <= state0;
            else
                stage <= state2;
        end
endmodule //control

module pc(input clk, reset, jump,
        input [7:0] jmpaddr,
        output reg[7:0] data);
    
    always @(posedge clk) begin
        if (reset == 1)
            data <= 8'b0;
        else if (reset == 0)
        begin
            if (jump == 1)
                data <= jmpaddr;
            else
                data <= data + 1;
        end
    end
endmodule //pc
