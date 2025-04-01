`timescale 1ns/1ps
 module iram#(parameter COL_NUM=4,COL_WIDTH=8)(input    logic [31:0] addr,
             output logic [31:0] rd);
    logic [COL_WIDTH-1:0] RAM[0:2047] [COL_NUM-1:0];
//    initial
//       $readmemh("riscvtest.txt",RAM);
    // Initialize RAM with example instructions or data
    // integer i;
    initial begin
        integer i,j;
        for(i=0;i<1023;i=i+1) begin
            for(j=0;j<COL_NUM;j=j+1) begin
                RAM[i][j]={COL_WIDTH{1'b0}};
            end
        end
        //  for (i = 9; i < 64; i = i + 1) begin
        //      RAM[i] = 32'h00000000;
        //  end
        // RAM[0] = 32'h00500093; // addi x1, x0 ,5
        // RAM[4] = 32'h00500113; // addi x2, x0 ,5
        // // RAM[4] = 32'h00508093; // addi x1, x1 ,5
        // // test BEQ
        // RAM[8]=32'h3e208363; // beq x1,x2,998
        // RAM[12]=32'h38309263; // bne x1,x3,900
        // // RAM[12] = 32'h00500093;
        // RAM[16]=32'h00500113; // addi x2,x0,5
        // RAM[20]=32'h384000ef; // jal x1, 900
        // RAM[24]=32'h00064097; // auipc x1, 100
        // RAM[28]=32'h000082e7; // jalr x5, 0(x1)
        // // RAM[4]=32'h0000a283; // lw x5, 0(x1)
        // // RAM[8]=32'h00400113; // addi x2, x0, 4
        // // RAM[12]=32'h00012283;//lw x5, 0(x2)
        // // RAM[16] = 32'h00500093; // addi x1, x0 ,5
        // // RAM[20] = 32'h00010183; //lb x3,0(x2)
        
        // // RAM[24] = 32'h00112023; //sw x1,0(x2)
        // // RAM[28] = 32'h00500093; // addi x1, x0 ,5
        // // RAM[32]=32'h00012283;//lw x5, 0(x2)
        // RAM[32] = 32'h01200293; // addi x5, x0, 18
        // RAM[36] = 32'h00512023; //sw x5,0(x2)
        // RAM[40]=32'h00012303;//lw x6, 0(x2)
        // RAM[44] = 32'h00000013; //nop
        // RAM[48] = 32'h00000013; //nop
        // RAM[52] = 32'h00000013; //nop
        // RAM[56] = 32'h00000013; //nop
      $readmemh("imem.hex", RAM);
//        RAM[64] = 32'h00000013; //nop
        //     instruction = 32'h38309263; // bne x1,x3,900
        //     instruction = 32'h 00500113; // addi x2,x0,5
        //     instruction = 32'h384000ef; // jal x1, 900
        //     instruction = 32'h00064097; // auipc x1, 100
        //     instruction = 32'h000082e7; // jalr x5, 0(x1)
            // instruction = 32'h0000a283; // lw x5, 0(x1)
        
    end
    // assign rd = {RAM[addr[31:2]],}; // word aligned would be 31:2
    // assign rd= {RAM[addr[31:2]][0],RAM[addr[31:2]][1],RAM[addr[31:2]][2],RAM[addr[31:2]][3]};
    always_comb begin
    rd[7:0]   = RAM[addr[31:2]][0]; // Column 0 (LSB)
    rd[15:8]  = RAM[addr[31:2]][1]; // Column 1
    rd[23:16] = RAM[addr[31:2]][2]; // Column 2
    rd[31:24] = RAM[addr[31:2]][3]; // Column 3 (MSB)
end
endmodule