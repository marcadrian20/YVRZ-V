`timescale 1ns/1ps
module ram#(parameter DEPTH=15,COL_NUM=4,COL_WIDTH=8,WIDTH=COL_NUM*COL_WIDTH)
           (input  logic              clk,
            input  logic [COL_NUM-1:0]we,
            // input  logic             rd,
            input  logic [WIDTH-1:0] addr,//byte address
            input  logic [WIDTH-1:0] DATA_IN,
            output logic [WIDTH-1:0] DATA_OUT);
    (* syn_ramstyle = "bsram" *) logic [COL_WIDTH-1:0] MEMORY [0:2**DEPTH-1][COL_NUM-1:0];
//    logic [WIDTH-1:0] MEMORY[2**DEPTH-1:0];
    ////////////////////////////////////////
    //we->write enable certain bytes      //
    //DEPTH->addr width                   //
    //WIDTH->Data width                   //
    //COL_NUM->number of collumns         //
    //COL_WIDTH->width of each collumn    //
    //DATA_IN is syncronously written     //
    //DATA_OUT is combinationally read    //
    ////////////////////////////////////////
    //This is a static RAM module asa a   //
    //placeholder for the real world DRAM //
    ////////////////////////////////////////
    //handle somehow the store instructions
    //TODO make byte addresable ram
    initial begin
        integer i,j;
        for(i=0;i<2**DEPTH;i=i+1) begin
            for(j=0;j<COL_NUM;j=j+1) begin
                MEMORY[i][j]={COL_WIDTH{1'b0}};
            end
        end
        // //at adress 4 we shul dhave 5
        // MEMORY[1][0]=8'b00000111;
        // MEMORY[1][1]=8'b00000110;
        // MEMORY[1][2]=8'b00000101;
        // MEMORY[1][3]=8'b00000100;
//      $readmemh("dmem.hex", MEMORY);
    end

    logic [WIDTH-1:0] word_addr;
    logic [1:0] byte_offset;
    assign word_addr=addr[WIDTH-1:2];
    assign byte_offset=addr[1:0];
    integer  i;
    // always_ff @(posedge clk) begin
    //     // if(we[0]) MEMORY[addr]<=DATA_IN;
    //     for(i=0;i<COL_NUM;i=i+1) begin
    //         if(we[i]) MEMORY[word_addr][i]<=DATA_IN[i*COL_WIDTH+:COL_WIDTH];
    //     end
    //     for(i=0;i<COL_NUM;i=i+1) begin
    //         DATA_OUT[i*COL_WIDTH+:COL_WIDTH]<=MEMORY[word_addr][i];
    //     end
    // end
    always_ff @(posedge clk) begin
        for(i=0;i<COL_NUM;i=i+1) begin
            DATA_OUT[i*COL_WIDTH+:COL_WIDTH]<=we[i]?DATA_IN[i*COL_WIDTH+:COL_WIDTH]:MEMORY[word_addr][i];
            if(we[i]) MEMORY[word_addr][i]<=DATA_IN[i*COL_WIDTH+:COL_WIDTH];
        end
    end
        // DATA_OUT<=MEMORY[addr];
//    assign DATA_OUT=MEMORY[addr];

endmodule