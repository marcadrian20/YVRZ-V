.section .text
.globl _start

_start:
    # Initialize stack pointer to end of DMEM
    li sp, 0x3FFC    # End of DMEM (4095*4 = 16380 = 0x3FFC)

    # Initialize a test counter in t6
    li t6, 0

    # ==========================================
    # Register-Immediate Instructions
    # ==========================================
    
    # LUI test
    lui t0, 0xABCDE
    li t1, 0xABCDE000
    bne t0, t1, test_failed
    addi t6, t6, 1    # Test 1 passed
    
    # AUIPC test
    auipc t0, 0x1
    srli t0, t0, 12    # Upper bits should not be zero
    beq t0, zero, test_failed
    addi t6, t6, 1    # Test 2 passed
    
    # ADDI test
    addi t0, zero, 100
    addi t1, t0, 200
    li t2, 300
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 3 passed
    
    # SLTI test
    addi t0, zero, 10
    slti t1, t0, 11
    beq t1, zero, test_failed
    slti t1, t0, 5
    bne t1, zero, test_failed
    addi t6, t6, 1    # Test 4 passed
    
    # SLTIU test
    addi t0, zero, -1    # This is the largest unsigned number
    sltiu t1, t0, 0
    bne t1, zero, test_failed
    sltiu t1, zero, -1
    beq t1, zero, test_failed
    addi t6, t6, 1    # Test 5 passed
    
    # XORI test
    li t0, 0x0F0F0F0F
    xori t1, t0, 0x3FF
    li t2, 0x0F0F0CF0
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 6 passed
    
    # ORI test
    li t0, 0x0F0F0F0F
    ori t1, t0, 0x3FF
    li t2, 0x0F0F0FFF
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 7 passed
    
    # ANDI test
    li t0, 0x0F0F0F0F
    andi t1, t0, 0x3FF
    li t2, 0x0000030F
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 8 passed
    
    # SLLI test
    li t0, 0x00000001
    slli t1, t0, 4
    li t2, 0x00000010
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 9 passed
    
    # SRLI test
    li t0, 0x00001000
    srli t1, t0, 4
    li t2, 0x00000100
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 10 passed
    
    # SRAI test
    li t0, 0xF0000010
    srai t1, t0, 4
    li t2, 0xFF000001
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 11 passed
    
    # ==========================================
    # Register-Register Instructions
    # ==========================================
    
    # ADD test
    li t0, 100
    li t1, 200
    add t2, t0, t1
    li t3, 300
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 12 passed
    
    # SUB test
    li t0, 300
    li t1, 100
    sub t2, t0, t1
    li t3, 200
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 13 passed
    
    # SLL test
    li t0, 0x00000001
    li t1, 4
    sll t2, t0, t1
    li t3, 0x00000010
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 14 passed
    
    # SLT test
    li t0, 10
    li t1, 20
    slt t2, t0, t1
    li t3, 1
    bne t2, t3, test_failed
    slt t2, t1, t0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 15 passed
    
    # SLTU test
    li t0, -1    # Largest unsigned number
    li t1, 1
    sltu t2, t1, t0
    li t3, 1
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 16 passed
    
    # XOR test
    li t0, 0x0F0F0F0F
    li t1, 0xF0F0F0F0
    xor t2, t0, t1
    li t3, 0xFFFFFFFF
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 17 passed
    
    # SRL test
    li t0, 0x00000100
    li t1, 4
    srl t2, t0, t1
    li t3, 0x00000010
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 18 passed
    
    # SRA test
    li t0, 0xF0000010
    li t1, 4
    sra t2, t0, t1
    li t3, 0xFF000001
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 19 passed
    
    # OR test
    li t0, 0x0F0F0F0F
    li t1, 0xF0F0F0F0
    or t2, t0, t1
    li t3, 0xFFFFFFFF
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 20 passed
    
    # AND test
    li t0, 0x0F0F0F0F
    li t1, 0xFFFF0000
    and t2, t0, t1
    li t3, 0x0F0F0000
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 21 passed
    
    # ==========================================
    # Memory Access Instructions
    # ==========================================
    
    # SW/LW test
    la t0, test_data
    li t1, 0xDEADBEEF
    sw t1, 0(t0)
    lw t2, 0(t0)
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 22 passed
    
    # SH/LH test
    li t1, 0xABCD
    sh t1, 4(t0)
    lhu t2, 4(t0)
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 23 passed
    
    # SB/LB test
    li t1, 0x5A
    sb t1, 8(t0)
    lb t2, 8(t0)
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 24 passed
    
    # LHU test
    li t1, 0xFFAB
    sh t1, 12(t0)
    lhu t2, 12(t0)
    li t3, 0x0000FFAB
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 25 passed
    
    # LBU test
    li t1, 0x80
    sb t1, 16(t0)
    lbu t2, 16(t0)
    li t3, 0x00000080
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 26 passed
    
    # ==========================================
    # Control Flow Instructions
    # ==========================================
    
    # JAL test
    jal t0, jal_target
    j test_failed  # Should not reach here
jal_target:
    # Check if the link address is reasonable
    addi t1, t0, -4
    sub t1, t0, t1
    li t2, 4
    bne t1, t2, test_failed
    addi t6, t6, 1    # Test 27 passed
    
    # JALR test
    la t0, jalr_target
    jalr t1, t0, 0
    j test_failed  # Should not reach here
jalr_target:
    # Check if the return address is reasonable
    la t0, test_failed
    beq t1, t0, test_failed
    addi t6, t6, 1    # Test 28 passed
    
    # BEQ test
    li t0, 10
    li t1, 10
    beq t0, t1, beq_target
    j test_failed  # Should not reach here
beq_target:
    addi t6, t6, 1    # Test 29 passed
    
    # BNE test
    li t0, 10
    li t1, 20
    bne t0, t1, bne_target
    j test_failed  # Should not reach here
bne_target:
    addi t6, t6, 1    # Test 30 passed
    
    # BLT test
    li t0, 10
    li t1, 20
    blt t0, t1, blt_target
    j test_failed  # Should not reach here
blt_target:
    addi t6, t6, 1    # Test 31 passed
    
    # BGE test
    li t0, 20
    li t1, 10
    bge t0, t1, bge_target
    j test_failed  # Should not reach here
bge_target:
    addi t6, t6, 1    # Test 32 passed
    
    # BLTU test
    li t0, 10
    li t1, 20
    bltu t0, t1, bltu_target
    j test_failed  # Should not reach here
bltu_target:
    addi t6, t6, 1    # Test 33 passed
    
    # BGEU test
    li t0, 20
    li t1, 10
    bgeu t0, t1, bgeu_target
    j test_failed  # Should not reach here
bgeu_target:
    addi t6, t6, 1    # Test 34 passed
    
    # Success - all tests passed! Store the results
    j test_passed

test_failed:
    # Store the failed test number at test_result
    la t0, test_result
    sw t6, 0(t0)
    li t1, 0xFFFFFFFF
    sw t1, 4(t0)
    # Also store at the very end of DMEM for easy checking
    li t0, 0x3FF8  # Last two words in DMEM
    sw t6, 0(t0)
    sw t1, 4(t0)
    j end

test_passed:
    # Store the success indicator at test_result
    la t0, test_result
    sw t6, 0(t0)
    li t1, 0xAA55AA55
    sw t1, 4(t0)
    # Also store at the very end of DMEM for easy checking
    li t0, 0x3FF8  # Last two words in DMEM
    sw t6, 0(t0)
    sw t1, 4(t0)

end:
    # Loop forever
    j end
    
.section .data
.align 4
test_data:
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    
test_result:
    .word 0    # Test number
    .word 0    # Success/failure indicator
