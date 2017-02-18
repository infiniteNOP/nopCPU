module pc(input clk, reset, jump, freeze,
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
                data <= freeze? data : data + 1;
        end
    end
endmodule //pc
