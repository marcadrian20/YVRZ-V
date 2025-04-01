`timescale 1ns/1ps
module CSRUnit(input logic clk,
               input logic reset,
               input logic csr_op,
               input logic [2:0] csr_type,
               input logic [11:0] csr_addr,
               input logic [31:0] csr_in,
               input logic [31:0] pc_on_exception,
               input logic ill_instr_exception,
               input logic ecall_exception,
               input logic ebreak_exception,
               input logic misaligned_store_exception,
               input logic misaligned_load_exception,
               output logic [31:0] csr_out,
               output logic [31:0] trap_vector,
               output logic trap_REQ);
//REF:https://five-embeddev.com/riscv-priv-isa-manual/Priv-v1.12/priv-csrs.html#chap:priv-csrs//
//////////////////////////////
//     MXL      |      XLEN     //
//      1       |       32      //
//      2       |       64      //
//      3       |       128     //
//////////////////////////////
//WE CONSIDER XLEN=32           //
//////////////////////////////
/////CSR OP TYPES//////
localparam ECALL=3'b000;
localparam EBREAK=3'b000;
localparam MRET=3'b110;
localparam CSRRW=3'b001;
localparam CSRRS=3'b010;
localparam CSRRC=3'b011;
localparam XLEN=32;
localparam MXL=1;
//////Privilage Levels//////////
localparam [1:0]U_MODE=2'b00;
localparam [1:0]S_MODE=2'b01;
localparam [1:0]M_MODE=2'b11;
//////FEATURES CONFIGURATION//////////
// parameter bit ENABLE_S_MODE=1'b1;
// parameter bit ENABLE_U_MODE=1'b1;
//add more features here
//////Machine Information Registers//////////
localparam mvendorid_addr=12'hF11; 
localparam marchid_addr=12'hF12;
localparam mimpid_addr=12'hF13;
localparam mhartid_addr=12'hF14;
localparam mconfigptr_addr=12'hF15;
//////Machine Trap Setup//////////
localparam mstatus_addr=12'h300;
localparam misa_addr=12'h301;
localparam medeleg_addr=12'h302;
localparam mideleg_addr=12'h303;
localparam mie_addr=12'h304;
localparam mtvec_addr=12'h305; 
localparam mcounteren_addr=12'h306;
localparam mstatush_addr=12'h310;
//////Machine Trap Handling//////////
localparam mscratch_addr=12'h340;
localparam mepc_addr=12'h341;
localparam mcause_addr=12'h342;
localparam mtval_addr=12'h343;
localparam mip_addr=12'h344;
localparam mtinst_addr=12'h34A;
localparam mtval2_addr=12'h34B;
//////Machine Configuration//////////
// localparam menvcfg_addr=12'h30A;
// localparam menvcfgh_addr=12'h31A;
// localparam mseccfg_addr=12'h747;
// localparam mseccfgh_addr=12'h757;
//////Machine Counter/Timers//////////
// localparam mcycle_addr=12'hB00;
// localparam minstret_addr=12'hB02;

//////MCAUSE VALS AFTER TRAP///////////////////////////////////////
//NON-INTERRUPTS//(interrupt=0)
localparam MISALIGN_INSTR_ADDR_CAUSE=0;
localparam INSTR_ACCESS_FAULT_CAUSE=1;
localparam ILL_INSTR_CAUSE=2;
localparam EBREAK_CAUSE=3;
localparam LOAD_MISALIGN_CAUSE=4;
localparam LOAD_ACCESS_FAULT_CAUSE=5;
localparam STORE_MISALIGN_CAUSE=6;
localparam STORE_ACCESS_FAULT_CAUSE=7;
localparam ECALL_U_CAUSE=8;
localparam ECALL_S_CAUSE=9;
localparam ECALL_M_CAUSE=11;
localparam INSTR_PAGE_FAULT_CAUSE=12;
localparam LOAD_PAGE_FAULT_CAUSE=13;
localparam STORE_PAGE_FAULT_CAUSE=15;
localparam SW_CHECK_CAUSE=18;
localparam HW_ERR_CAUSE=19;
//INTERRUPTS//(interrupt=1)////////////////////////////////////////
//SUPERVISOR MODE
localparam SUPERVISOR_SW_INT_CAUSE=1;
localparam SUPERVISOR_TIMER_INT_CAUSE=5;
localparam SUPERVISOR_EXT_INT_CAUSE=9;
//MACHINE MODE
localparam MACHINE_SW_INT=3;
localparam MACHINE_TIMER_INT=7;
localparam MACHINE_EXT_INT=11;
//IF EXCP CODE >=16 && INT => FOR PLATFORM USE #TODO
/////////////////////////////////////////////////////////////////////
logic exception,trapped;
logic ill_csr,csr_acces_permitted;
logic [1:0] current_privilege,previous_privilege;
logic [31:0] misa,mvendorid,marchid,mimpid,mhartid,mstatus,mstatush,mideleg,medeleg,mie,mtvec,mcounteren,mscratch,mepc,mcause,mtval,mip,mtinst;

assign exception=/*ill_instr_exception|*/ecall_exception|ebreak_exception|misaligned_store_exception|misaligned_load_exception;
always_comb begin 
    csr_acces_permitted=current_privilege>=csr_addr[9:8];//check the curr privilage against the csr privilage for access
    // case(csr_addr)
    //     mstatus_addr,misa_addr,mscra,mtvec_addr,mcause_addr:
    //         csr 
    // endcase
end
always_comb begin
    csr_out=32'b0;
    ill_csr=1'b0;
    if(csr_acces_permitted)
        case(csr_addr)
            mstatus_addr: csr_out=mstatus;
            misa_addr: csr_out=misa;
            mtvec_addr: csr_out=mtvec;
            mcause_addr: csr_out=mcause;
            mscratch_addr: csr_out=mscratch;
            mepc_addr: csr_out=mepc;
            mtval_addr: csr_out=mtval;
            medeleg_addr: csr_out=medeleg;
            mideleg_addr: csr_out=mideleg;
            mie_addr: csr_out=mie;
            default: ill_csr=1'b1;
        endcase 
    else
        ill_csr=1'b1;
end
logic test;
always_ff @(posedge clk) begin
    if(reset) begin
        misa<=32'b0100_0000_0000_0000_0000_0000_1000_0000;
        mvendorid<=32'b0;//return not implemented
        marchid<=32'b0;//return not implemented
        mimpid<=32'b0;//return not implemented
        mhartid<=32'b0;//HART ID, first HART should be 0
//        mconfigptr<=32'b0;//return not implemented
        mcause<=32'b0;//absolute/most complete reset
        current_privilege<=M_MODE;//on reset we are in machine mode
        previous_privilege<=M_MODE;
        mstatus<=32'b0;
        mscratch<=32'b0;
        medeleg<=32'b0;
        mideleg<=32'b0;
        mie<=32'b0;
        mepc<=32'b0;
        mtval<=32'b0;
        mtvec<=32'b0;
        trap_vector<=32'b0;
        trapped<=1'b0;
        trap_REQ<=1'b0;
        test<=1'b0;
    end
    else begin
        trap_REQ<=1'b0;
        if(!ill_csr&&csr_op) begin
            case(csr_type)
                CSRRW: begin
                    case(csr_addr)
                        mstatus_addr: mstatus<=csr_in;
                        misa_addr: misa<=csr_in;
                        mtvec_addr: mtvec<=csr_in;
                        mcause_addr: mcause<=csr_in;
                        mscratch_addr: mscratch<=csr_in;
                        mepc_addr: mepc<=csr_in;
                        mtval_addr: mtval<=csr_in;
                    endcase
                end
                CSRRS: begin
                    case(csr_addr)
                        mstatus_addr: mstatus<=mstatus|csr_in;
                        misa_addr: misa<=misa|csr_in;
                        mtvec_addr: mtvec<=mtvec|csr_in;
                        mcause_addr: mcause<=mcause|csr_in;
                        mscratch_addr: mscratch<=mscratch|csr_in;
                        mepc_addr: mepc<=mepc|csr_in;
                        mtval_addr: mtval<=mtval|csr_in;
                    endcase
                end
                CSRRC: begin
                    case(csr_addr)
                        mstatus_addr: mstatus<=mstatus&(~csr_in);
                        misa_addr: misa<=misa&(~csr_in);
                        mtvec_addr: mtvec<=mtvec&(~csr_in);
                        mcause_addr: mcause<=mcause&(~csr_in);
                        mscratch_addr: mscratch<=mscratch&(~csr_in);
                        mepc_addr: mepc<=mepc&(~csr_in);
                        mtval_addr: mtval<=mtval&(~csr_in);
                    endcase
                end
                MRET: begin ///#TODO FIX THIS. In the encodint, MRET has the csr_addr 302 which coresponds to medeleg.
                    //I abuse this to force ill_csr to 0 in order to enter this case. This is a temporary solution
                        trap_REQ<=1'b1;
                        mstatus[3]<=mstatus[7];//MIE<=MPIE
                        mstatus[7]<=1'b1;//MPIE<=1
                        trap_vector<=mepc;
                        trapped<=1'b0;
                end
                
            endcase
        end
        if(exception&&!trapped) begin
            trapped<=1'b1;
            trap_REQ<=1'b1;
            mepc<=pc_on_exception;
            trap_vector<=mtvec;
            mstatus[7]<=mstatus[3];//MPIE<=MIE
            mstatus[3]<=1'b0;//MIE<=0 disable interrupts
            if(ecall_exception) begin
                mcause<=ECALL_M_CAUSE;
            end
            else if(ebreak_exception) begin
                mcause<=EBREAK_CAUSE;
            end
            else if(misaligned_store_exception) begin
                mcause<=STORE_MISALIGN_CAUSE;
            end
            else if(misaligned_load_exception) begin
                mcause<=LOAD_MISALIGN_CAUSE;
            end
            else 
                mcause<=ILL_INSTR_CAUSE;
        end  
    end
end        


    

endmodule