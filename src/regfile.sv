`timescale 1ns/1ps
module regfile(input  logic         clk,
               input  logic         WE,
               input  logic [4:0]  readPort1SEL,readPort2SEL,writePortSEL,
               input  logic [31:0] writePort,
               output logic [31:0] readPort1, readPort2)/* synthesis syn_ramstyle = "distributed_ram" */;

    logic [31:0] regs[31:0];
    ////////////////////////////////////////////////////////////
    //three ported, dual ported reading, single ported write.///
    //sync write on falling edge                             ///
    //sync reads on rising edge                              //
    ////////////////////////////////////////////////////////////
    //RDport1,RDport2->read port register select             ///
    //WE->Write enable to the third/write port               ///
    //WRport->write register selector port                   ///
    ////////////////////////////////////////////////////////////
    integer i;
    initial begin
       for(i=0;i<32;i=i+1) begin
           regs[i]=32'b0;
       end
    end
    always_ff @(negedge clk)//negedge clk on pipelined , posedge clk on single cycle
        if(WE&&(writePortSEL!=5'b0)) regs[writePortSEL]<=writePort;
//    always_ff @(posedge clk) begin
    assign readPort1=(readPort1SEL!=5'b0)?regs[readPort1SEL]:32'b0;
    assign readPort2=(readPort2SEL!=5'b0)?regs[readPort2SEL]:32'b0;
//    end
endmodule
