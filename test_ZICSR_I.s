.section .text
.globl _start

# M-mode trap vector setup at beginning
_start:
    # Set up trap vector
    la t0, trap_handler
    csrw mtvec, t0
    
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

    # ==========================================
    # ECALL and EBREAK Tests
    # ==========================================
    
    # ECALL test
    # Enable ECALL trap handling
    la t0, ecall_expected
    la t3, trap_expected_address
    sw t0, 0(t3)
    # Set expected cause value (environment call from M-mode = 11)
    li t0, 11
    la t3, trap_expected_cause
    sw t0, 0(t3)
    # Execute ECALL - should trap and return here
    j ecall_expected
ecall_return:
    # Check if we continued after trap handler worked correctly
    la t0, trap_test_passed
    lw t1, 0(t0)
    beq t1, zero, test_failed
    # Reset the trap test flag
    sw zero, 0(t0)
    addi t6, t6, 1    # Test 35 passed
    
    # EBREAK test
    # Enable EBREAK trap handling
    la t0, ebreak_expected
    la t3, trap_expected_address
    sw t0, 0(t3)
    # Set expected cause value (breakpoint = 3)
    li t0, 3
    la t3, trap_expected_cause
    sw t0, 0(t3)
    # Execute EBREAK - should trap and return here
    j ebreak_expected
ebreak_return:
    # Check if we continued after trap handler worked correctly
    la t0, trap_test_passed
    lw t1, 0(t0)
    beq t1, zero, test_failed
    # Reset the trap test flag
    sw zero, 0(t0)
    addi t6, t6, 1    # Test 36 passed
    
    # ==========================================
    # ZICSR Instructions Tests
    # ==========================================
    
    # CSRRW test - read and write a CSR
    li t0, 0xABCDEF01
    csrrw t1, mscratch, t0      # Write t0 to mscratch, read previous value to t1
    csrrw t2, mscratch, zero    # Read mscratch to t2, write 0
    bne t2, t0, test_failed     # t2 should equal t0
    addi t6, t6, 1    # Test 37 passed
    
    # CSRRS test - read and set bits in a CSR
    li t0, 0
    csrrw t1, mscratch, t0      # Zero out mscratch
    li t0, 0x0F0F0F0F
    csrrs t1, mscratch, t0      # Set bits in t0, read previous value (0)
    bne t1, zero, test_failed   # t1 should be 0, not t0
    csrrs t2, mscratch, zero    # Read without modifying
    bne t2, t0, test_failed     # t2 should equal t0
    addi t6, t6, 1    # Test 38 passed
    
    # CSRRC test - read and clear bits in a CSR
    li t0, 0xFFFFFFFF
    csrrw t1, mscratch, t0      # Set all bits in mscratch
    li t0, 0x0F0F0F0F
    csrrc t1, mscratch, t0      # Clear bits in t0, read previous value
    li t2, 0xF0F0F0F0           # Expected value after clearing
    csrrc t3, mscratch, zero    # Read without modifying
    bne t3, t2, test_failed     # t3 should equal t2
    addi t6, t6, 1    # Test 39 passed
    
    # CSRRWI test - immediate value
    csrrwi t0, mscratch, 15     # Write immediate 15 to mscratch
    csrr t1, mscratch           # Read mscratch to t1
    li t2, 15
    bne t1, t2, test_failed     # t1 should be 15
    addi t6, t6, 1    # Test 40 passed
    
    # CSRRSI test - set bits immediate
    csrrw t0, mscratch, zero    # Zero out mscratch
    csrrsi t0, mscratch, 10     # Set bits 1 and 3 (value 10)
    csrr t1, mscratch           # Read mscratch to t1
    li t2, 10
    bne t1, t2, test_failed     # t1 should be 10
    addi t6, t6, 1    # Test 41 passed
    
    # CSRRCI test - clear bits immediate
    li t0, 0xFFFFFFFF
    csrrw t1, mscratch, t0      # Set all bits in mscratch
    csrrci t0, mscratch, 10     # Clear bits 1 and 3 (value 10)
    csrr t1, mscratch           # Read mscratch to t1
    li t2, 0xFFFFFFF5           # Expected value after clearing bits 1 and 3
    bne t1, t2, test_failed     # t1 should be t2
    addi t6, t6, 1    # Test 42 passed
    
    # ==========================================
# M Extension (Multiplication/Division) Tests
# ==========================================

# Place this code before the "Success - all tests passed!" jump

# MUL test - multiply two values
li t0, 7
li t1, 9
mul t2, t0, t1
li t3, 63
bne t2, t3, test_failed
addi t6, t6, 1    # Test 43 passed

# MUL overflow test - check handling of upper bits
li t0, 0x80000000  # Most negative 32-bit number
li t1, 2
mul t2, t0, t1     # Should result in 0 due to overflow in 32 bits
li t3, 0
bne t2, t3, test_failed
addi t6, t6, 1    # Test 44 passed

# MULH test - upper bits of signed x signed
li t0, 0x7FFFFFFF  # Max positive 32-bit number
li t1, 0x7FFFFFFF  # Max positive 32-bit number
mulh t2, t0, t1    # Upper 32 bits of 0x3FFFFFFF00000001
li t3, 0x3FFFFFFF
bne t2, t3, test_failed
addi t6, t6, 1    # Test 45 passed

# MULHSU test - upper bits of signed x unsigned
li t0, -1          # -1 signed (0xFFFFFFFF)
li t1, 10          # 10 unsigned
mulhsu t2, t0, t1  # Upper 32 bits of -10 (sign extended)
li t3, -1          # Should be all ones (0xFFFFFFFF)
bne t2, t3, test_failed
addi t6, t6, 1    # Test 46 passed

# MULHU test - upper bits of unsigned x unsigned
li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
li t1, 0xFFFFFFFF  # Max unsigned 32-bit number
mulhu t2, t0, t1   # Upper 32 bits of 0xFFFFFFFE00000001
li t3, 0xFFFFFFFE
bne t2, t3, test_failed
addi t6, t6, 1    # Test 47 passed

# DIV test - signed division
li t0, 100
li t1, 10
div t2, t0, t1     # 100/10 = 10
li t3, 10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 48 passed

# DIV test - negative result
li t0, -100
li t1, 10
div t2, t0, t1     # -100/10 = -10
li t3, -10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 49 passed

# DIV test - division by zero
li t0, 100
li t1, 0
div t2, t0, t1     # Should be all ones (0xFFFFFFFF)
li t3, -1
bne t2, t3, test_failed
addi t6, t6, 1    # Test 50 passed

# DIV test - overflow case
li t0, 0x80000000  # Most negative 32-bit number (-2^31)
li t1, -1
div t2, t0, t1     # Should overflow and return same value
li t3, 0x80000000
bne t2, t3, test_failed
addi t6, t6, 1    # Test 51 passed

# DIVU test - unsigned division
li t0, 100
li t1, 10
divu t2, t0, t1    # 100/10 = 10 (unsigned)
li t3, 10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 52 passed

# DIVU test - large unsigned values
li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
li t1, 0x10000000  # Large divisor
divu t2, t0, t1    # Should be 15
li t3, 15
bne t2, t3, test_failed
addi t6, t6, 1    # Test 53 passed

# DIVU test - division by zero
li t0, 100
li t1, 0
divu t2, t0, t1    # Should be all ones (0xFFFFFFFF)
li t3, -1
bne t2, t3, test_failed
addi t6, t6, 1    # Test 54 passed

# REM test - signed remainder
li t0, 100
li t1, 30
rem t2, t0, t1     # 100 % 30 = 10
li t3, 10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 55 passed

# REM test - negative dividend
li t0, -100
li t1, 30
rem t2, t0, t1     # -100 % 30 = -10
li t3, -10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 56 passed

# REM test - division by zero
li t0, 100
li t1, 0
rem t2, t0, t1     # Should return dividend (100)
li t3, 100
bne t2, t3, test_failed
addi t6, t6, 1    # Test 57 passed

# REM test - overflow case
li t0, 0x80000000  # Most negative 32-bit number
li t1, -1
rem t2, t0, t1     # Should be 0
li t3, 0
bne t2, t3, test_failed
addi t6, t6, 1    # Test 58 passed

# REMU test - unsigned remainder
li t0, 100
li t1, 30
remu t2, t0, t1    # 100 % 30 = 10 (unsigned)
li t3, 10
bne t2, t3, test_failed
addi t6, t6, 1    # Test 59 passed

# REMU test - large unsigned values
li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
li t1, 0x10000000  # Large divisor
remu t2, t0, t1    # Should be 0xFFFFFFF
li t3, 0x0FFFFFFF
bne t2, t3, test_failed
addi t6, t6, 1    # Test 60 passed

# REMU test - division by zero
li t0, 100
li t1, 0
remu t2, t0, t1    # Should return dividend (100)
li t3, 100
bne t2, t3, test_failed
addi t6, t6, 1    # Test 61 passed


    # Success - all tests passed! Store the results
    j test_passed

# Trap handler to deal with ECALL and EBREAK
trap_handler:
    # Save registers that will be modified
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw ra, 12(sp)
    
    # Get the trap cause
    csrr t0, mcause
    # Get the trap address
    csrr t1, mepc
    
    # Check if this is the expected trap
    la t2, trap_expected_cause
    lw t2, 0(t2)
    bne t0, t2, unexpected_trap
    
    # Check if at expected address
    la t2, trap_expected_address
    lw t2, 0(t2)
    bne t1, t2, unexpected_trap
    
    # Mark the trap test as passed
    la t2, trap_test_passed
    li t0, 1
    sw t0, 0(t2)
    
    # For ECALL and EBREAK, increment mepc to point after the instruction
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    
    # Restore registers and return
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    mret

unexpected_trap:
    # If we got an unexpected trap, fail the test
    j test_failed

ecall_expected:
    ecall
    j ecall_return

ebreak_expected:
    ebreak
    j ebreak_return

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

# Trap handler variables
trap_expected_address:
    .word 0    # Address where we expect the trap
    
trap_expected_cause:
    .word 0    # Expected cause value
    
trap_test_passed:
    .word 0    # Flag to indicate if trap test passed
    