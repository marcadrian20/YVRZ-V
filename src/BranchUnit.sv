// module BranchUnit(
//                   input logic [31:0] srcA, srcB,
//                   input logic [31:0] BranchAddr,
//                   input logic [2:0] branchType,
//                   input logic branch,
//                   input logic jump,
//                   output logic branchTaken,
//                   output logic missaligned_exception,
//                   output logic [31:0] targetADDR);

//     // Pre-compute just what's needed - avoid full 32-bit comparisons when possible
//     // These synthesis attributes can help the tool optimize better
//     (* direct_enable = "yes" *) logic equal, signed_less, unsigned_less;
    
//     // Use bit-level operators for equality - often synthesizes to tree structure
//     assign equal = (srcA == srcB);
    
//     // Use explicit bit selection for sign comparison to avoid 32-bit operations
//     wire srcA_sign = srcA[31];
//     wire srcB_sign = srcB[31];
    
//     // Optimized sign comparison logic
//     assign signed_less = (srcA_sign != srcB_sign) ? srcA_sign : (srcA < srcB);
//     assign unsigned_less = (srcA < srcB);
    
//     // Direct indexing for branch conditions - avoids complex logic
//     wire [7:0] branch_conditions;
//     assign branch_conditions = {
//         ~unsigned_less,  // BGEU (7)
//         unsigned_less,   // BLTU (6)
//         ~signed_less,    // BGE  (5)
//         signed_less,     // BLT  (4)
//         1'b0,            // unused (3)
//         1'b0,            // unused (2)
//         ~equal,          // BNE  (1)
//         equal            // BEQ  (0)
//     };
    
//     // Use direct indexing without intermediate signal to reduce delay
//     wire condition_met = branch_conditions[branchType];
    
//     // Simplified target calculation - avoid conditional logic 
//     assign targetADDR = BranchAddr;
    
//     // Branch alignment check (just check lowest bits)
//     wire is_aligned = (targetADDR[1:0] == 2'b00);
    
//     // Single-stage branch decision logic
//     assign branchTaken = ((condition_met & branch) | jump) & is_aligned;
//     assign missaligned_exception = ((condition_met & branch) | jump) & ~is_aligned;
// endmodule
module BranchUnit(
                  input logic [31:0] srcA,srcB,
                  input logic [1:0] BranchAddr,
                  input logic [2:0] branchType,
                //   input logic zero,
                  input logic branch,
                  input logic jump,
                  output logic branchTaken,
                  output logic missaligned_exception
                //   output logic [1:0] targetADDR
                  )/*synthesis syn_dspstyle = "dsp" */;
    logic is_aligned;
    logic takeBranch;
    logic valid;
   logic equal,signed_comparison,unsigned_comparison/*synthesis syn_dspstyle = "dsp" */;
    assign equal=srcA==srcB/*synthesis syn_dspstyle = "dsp" */;
    assign unsigned_comparison=(srcA<srcB)/*synthesis syn_dspstyle = "dsp" */; 
    assign signed_comparison=($signed(srcA)<$signed(srcB))/*synthesis syn_dspstyle = "dsp" */;
    // assign targetADDR=(jump)?{BranchAddr[31:1],1'b0}:BranchAddr;
    // assign targetADDR=BranchAddr;
    assign is_aligned=(BranchAddr[1:0]==2'b00);
    assign valid=(takeBranch&branch)|jump;
    assign missaligned_exception=~is_aligned & valid;
    assign branchTaken=is_aligned & valid;
   always_comb begin
       case(branchType)/* synthesis parallel_case */ 
           3'b000: takeBranch=equal;
           3'b001: takeBranch=~equal;
           3'b100: takeBranch=signed_comparison;
           3'b101: takeBranch=~signed_comparison;
           3'b110: takeBranch=unsigned_comparison;
           3'b111: takeBranch=~unsigned_comparison;
           default:takeBranch=0;
       endcase
       //\/ ONE Hot muxing like down below is more efficient and yields ~1mhz
        // case(1'b1)
        //     ~branchType[2]: begin
        //         case(branchType[0]) 
        //             1'b0: takeBranch=equal;
        //             1'b1: takeBranch=~equal;
        //         endcase
        //     end
        //     branchType[1]: begin
        //         case(branchType[0]) 
        //             1'b0: takeBranch=signed_comparison;
        //             1'b1: takeBranch=~signed_comparison;
        //         endcase
        //     end
        //     branchType[0]: begin
        //         case(branchType[0]) 
        //             1'b0: takeBranch=unsigned_comparison;
        //             1'b1: takeBranch=~unsigned_comparison;
        //         endcase
        //     end
        //     default: takeBranch=0;
        // endcase
   end
endmodule
//^^^^^has 4 LUTs and 62ALUs
//\/32 ALus and 2 LUts
localparam C_extension=0;
// module BranchUnit(input logic [31:0] BranchAddr,
//                   input logic [2:0] branchType,
//                   input logic zero,
//                   input logic branch,
//                   input logic jump,
//                   output logic branchTaken,
//                   output logic missaligned_exception,
//                   output logic [31:0] targetADDR);

//     logic is_aligned;
//     logic takeBranch;
//     logic valid;
// //IN RV32I INSTRUCTIONS ARE 4 BYTE ALIGNED
// //JALR IS A MULTIPLE OF 2 BYTES, BUT STILL 4 BYTES ALIGNED


//     always_comb begin
//         takeBranch=1'b0;
//         case(branchType)
//             3'b000: takeBranch=zero;
//             3'b001: takeBranch=~zero;
//             3'b100: takeBranch=~zero;
//             3'b101: takeBranch=zero;
//             3'b110: takeBranch=~zero;
//             3'b111: takeBranch=zero;
//             default:takeBranch=1'b0;
//         endcase
//     end
// // instruction missalignment. 
//      assign targetADDR=(jump)?{BranchAddr[31:1],1'b0}:BranchAddr;
//      assign is_aligned=(targetADDR[1:0]==2'b00);
//      assign valid=(takeBranch&branch)|jump;
//      assign missaligned_exception=~is_aligned & valid;
//      assign branchTaken=is_aligned & valid;
// endmodule
////above one uses less alu resources but the critical path is longer because of the register comparation through the ALU

module AdressAdder(input logic [31:0] srcA,srcB,
             output logic [31:0] BranchAddr)/*synthesis syn_dspstyle = "dsp" */;

    assign BranchAddr=srcA+srcB;
endmodule