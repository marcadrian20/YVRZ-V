`timescale 1ns/1ps
module LoadStoreUnit(input logic [31:0] LoadData,
                     input logic [31:0] StoreData,
                     input logic [1:0] Address, 
                     input logic [2:0] funct3,
                     input logic mem_write,
                     input logic mem_read,
                     output logic [31:0] LoadDataOut,
                     output logic [31:0] StoreDataOut,
                     output logic misaligned_load_exception,
                     output logic misaligned_store_exception,
                     output logic [3:0] mem_write_req,
                     output logic mem_read_req);

    //|OPERATION|FUNCT3|MEM_READ|MEM_WRITE|ALIGNMENT|EXTENSION|
    //|---------|------|--------|---------|---------|---------|
    //| LB      | 000  |   1    |    0    |    1    |  SIGNED |
    //|---------|------|--------|---------|---------|---------|
    //| LH      | 001  |   1    |    0    |    2    |  SIGNED |
    //|---------|------|--------|---------|---------|---------|
    //| LB      | 010  |   1    |    0    |    4    |  SIGNED |
    //|---------|------|--------|---------|---------|---------|
    //| LBU     | 100  |   1    |    0    |    1    | UNSIGNED|
    //|---------|------|--------|---------|---------|---------|
    //| LHU     | 101  |   1    |    0    |    2    | UNSIGNED|
    //|---------|------|--------|---------|---------|---------|
    //| SB      | 000  |   0    |    1    |    1    |    X    |
    //|---------|------|--------|---------|---------|---------|
    //| SH      | 001  |   0    |    1    |    2    |    X    |
    //|---------|------|--------|---------|---------|---------|
    //| SW      | 010  |   0    |    1    |    4    |    X    |
    //|---------|------|--------|---------|---------|---------|

    //First we check address alignment on stores and loads
    //On unaligned access we raise an exception
    logic [1:0] alignment;
    logic is_aligned;
    logic [1:0] byte_enable;
    logic mem_write_valid;
    
    always_comb begin
        case(funct3[1:0])/* synthesis parallel_case */
            2'b00: is_aligned=1'b1; //LB|LBU|SB
            2'b01: is_aligned=~Address[0]; //LH|LHU|SH
            2'b10: is_aligned=~(|Address[1:0]); //LW|SW
            default: is_aligned=1'b0;
        endcase
    end

    always_comb begin
        LoadDataOut=32'b0;
        if(mem_read) begin 
            case(funct3)/* synthesis parallel_case */
                3'b000: LoadDataOut={{24{LoadData[7]}},LoadData[7:0]};//LB
                3'b001: LoadDataOut={{16{LoadData[15]}},LoadData[15:0]};//LH
                3'b010: LoadDataOut=LoadData;//LW
                3'b100: LoadDataOut={24'b0,LoadData[7:0]};//LBU
                3'b101: LoadDataOut={16'b0,LoadData[15:0]};//LHU
            endcase
        end            
        // if(mem_write)
    end
    always_comb begin
        StoreDataOut=32'b0;
        mem_write_req=4'b0;
        if(mem_write_valid) begin
            case(funct3)/* synthesis parallel_case */
                // 3'b000: begin
                //     StoreDataOut={StoreData[7:0],24'b0};//SB
                //     mem_write_req=4'b0001;
                // end
                // 3'b001: begin
                //     StoreDataOut={StoreData[15:0],16'b0};//SH
                //     mem_write_req=4'b0011;
                // end
                3'b000: begin
                    StoreDataOut={24'b0,StoreData[7:0]};//SB
                    mem_write_req=4'b0001;
                end
                3'b001: begin
                    StoreDataOut={16'b0,StoreData[15:0]};//SH
                    mem_write_req=4'b0011;
                end
                
                3'b010: begin
                    StoreDataOut=StoreData;//SW
                    mem_write_req=4'b1111;
                end
            endcase
        end
    end
    assign misaligned_load_exception = ~is_aligned & mem_read;
    assign misaligned_store_exception = ~is_aligned & mem_write;
    assign mem_write_valid=(is_aligned & mem_write);
    assign mem_read_req=is_aligned & mem_read; 
endmodule