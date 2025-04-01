module pipeline_reg #(parameter WIDTH=8,INIT_VALUE=0)
                (input logic clk,
                 input logic reset,
                 input logic en_n,
                 input logic [WIDTH-1:0] in,
                 output logic [WIDTH-1:0] out)/* synthesis syn_ramstyle = "distributed_ram" */;
    logic [WIDTH-1:0] REGISTER/* synthesis syn_ramstyle = "distributed_ram" */;
    always_ff @(posedge clk/* or posedge reset*/)
    begin
        if(reset)
            REGISTER<=INIT_VALUE;
        else if(~en_n)
            REGISTER<=in;
    end
    assign out=REGISTER;
endmodule