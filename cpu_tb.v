/* 
 * Testbench for simple 8-bit CPU.
 * Copyright (C) 2015, 16 John Tzonevrakis.
 * License exception for cpu_tb.v *ONLY*!
 *
 * This testbench is licensed under the terms of the ISC license:
 * Permission to use, copy, modify, and/or distribute this software for any 
 * purpose with or without fee is hereby granted, provided that the above 
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
 * DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER 
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, 
 * ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF 
 * THIS SOFTWARE.
 *
 *
*/

// Modifications done by Al Williams (of HackADay) visible here:
// Added small program and user memory for simulation
module programmem(input [7:0] pgmaddr, output [7:0] pgmdata);
    reg [7:0] pmemory[255:0];
    assign pgmdata=pmemory[pgmaddr];

    initial
        begin
            pmemory[0]=8'h82;
            pmemory[1]=8'hff;
            pmemory[2]=8'hb8;
				pmemory[3]=8'hb1;
				pmemory[4]=8'h83;
				pmemory[5]=8'h00;
				pmemory[6]=8'hb2;
            pmemory[7]=8'h93;
				pmemory[8]=8'ha1;
				pmemory[9]=8'h00;
    end
endmodule

// Simple user memory for simulation
module usermem(input clk, input [7:0] uaddr, input [7:0] udata_i,output [7:0] udata_o, input rw);
    reg [7:0] umemory[255:0];
    assign udata_o=rw?8'bZ:umemory[uaddr];
    always @(negedge clk) begin
        if (rw==1) umemory[uaddr] <= udata_i;
			end
    initial
    begin
        umemory[0]<=8'h00;
        umemory[1]<=8'h00;
        umemory[2]<=8'h00;
		  umemory[255]<=8'hde;
    end
endmodule

module cpu_tb;
    reg clk, reset, interrupt;
    wire [7:0] datamem_data, usermem_data_in, usermem_data_out, datamem_address, usermem_address, idata;
    wire rw;
    programmem pgm(datamem_address,idata);
    usermem umem(clk, usermem_address,usermem_data_out, usermem_data_in,rw);
cpu dut0 (
    .clk(clk), 
    .reset(reset), 
    .interrupt(interrupt), 
    .datamem_data(idata), 
    .usermem_data_in(usermem_data_in), 
    .datamem_address(datamem_address), 
    .usermem_address(usermem_address), 
    .usermem_data_out(usermem_data_out), 
    .rw(rw)
    );    initial
    begin
        $display("NopCPU testbench. All waveforms will be dumped to the dump.vcd file.");
        $dumpfile("waves.vcd");
        $dumpvars(0, dut0);
        $monitor("Clock: %b Reset: %b \nAddress (Datamem): %h Address: (Usermem): %h)\n Data (Datamem): %h Data (Usermem): %h R/W: %b\n Time: %d\n",clk,reset,datamem_address,usermem_address,datamem_data,usermem_data_out,rw,$time);
        clk = 1'b0;
        reset = 1'b1;
        interrupt = 1'b0;
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;
        end
        always begin
            forever begin
                #1 clk = !clk;
            end
        end
        /* Comment this out to test interrupts: */
        /*always
        begin
            #25 interrupt = ~interrupt;
            #2 interrupt = ~interrupt;
        end*/
endmodule //cpu_tb
