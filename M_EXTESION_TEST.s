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
    # Multiplication Instructions Tests
    # ==========================================
    
    # ---- MUL: Lower 32 bits of signed x signed product ----
    
    # MUL test 1: Small positive numbers
    li t0, 7
    li t1, 9
    mul t2, t0, t1
    li t3, 63
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 1 passed
    
    # MUL test 2: Negative x positive
    li t0, -5
    li t1, 10
    mul t2, t0, t1
    li t3, -50
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 2 passed
    
    # MUL test 3: Negative x negative (positive result)
    li t0, -5
    li t1, -10
    mul t2, t0, t1
    li t3, 50
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 3 passed
    
    # MUL test 4: Zero cases
    li t0, 0
    li t1, 123
    mul t2, t0, t1
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 4 passed
    
    # MUL test 5: Large numbers (lower 32 bits only)
    li t0, 0x12345678
    li t1, 0x87654321
    mul t2, t0, t1
    li t3, 0x70b88d78  # Lower 32 bits of 0x12345678 * 0x87654321
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 5 passed
    
    # MUL test 6: Overflow case
    li t0, 0x80000000  # Most negative 32-bit number (-2^31)
    li t1, 2
    mul t2, t0, t1
    li t3, 0           # Lower 32 bits only: -2^31 * 2 = -2^32 = 0 (lower 32 bits)
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 6 passed
    
    # ---- MULH: Upper 32 bits of signed x signed product ----
    
    # MULH test 1: Small positives (should be zero upper bits)
    li t0, 100
    li t1, 100
    mulh t2, t0, t1
    li t3, 0           # Upper bits should be 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 7 passed
    
    # MULH test 2: Large positives (with non-zero upper bits)
    li t0, 0x7FFFFFFF  # Max positive 32-bit number
    li t1, 0x7FFFFFFF  # Max positive 32-bit number
    mulh t2, t0, t1
    li t3, 0x3FFFFFFF  # Upper 32 bits of 0x3FFFFFFF00000001
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 8 passed
    
    # MULH test 3: Large negative x positive
    li t0, 0x80000000  # Most negative 32-bit number (-2^31)
    li t1, 0x7FFFFFFF  # Max positive 32-bit number
    mulh t2, t0, t1
    li t3, 0xC0000000  # Upper 32 bits correctly sign-extended
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 9 passed
    
    # MULH test 4: Negative x negative
    li t0, 0x80000000  # Most negative 32-bit number (-2^31)
    li t1, 0x80000000  # Most negative 32-bit number (-2^31)
    mulh t2, t0, t1
    li t3, 0x40000000  # Upper 32 bits of (-2^31 * -2^31)
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 10 passed
    
    # ---- MULHSU: Upper 32 bits of signed x unsigned product ----
    
    # MULHSU test 1: Positive signed x unsigned
    li t0, 0x7FFFFFFF  # Max positive 32-bit number (signed)
    li t1, 0xFFFFFFFF  # Max unsigned 32-bit number
    mulhsu t2, t0, t1
    li t3, 0x7FFFFFFE  # Upper 32 bits of signed x unsigned product
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 11 passed
    
    # MULHSU test 2: Negative signed x unsigned
    li t0, 0x80000000  # Most negative 32-bit number (-2^31)
    li t1, 0xFFFFFFFF  # Max unsigned 32-bit number
    mulhsu t2, t0, t1
    li t3, 0x80000000  # Upper 32 bits of signed x unsigned product
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 12 passed
    
    # MULHSU test 3: Negative signed (-1) x unsigned
    li t0, -1          # -1 signed (0xFFFFFFFF)
    li t1, 10          # 10 unsigned
    mulhsu t2, t0, t1  # Upper 32 bits of -10 (sign extended)
    li t3, -1          # Should be all ones (0xFFFFFFFF)
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 13 passed
    
    # ---- MULHU: Upper 32 bits of unsigned x unsigned product ----
    
    # MULHU test 1: Small values (zero upper bits)
    li t0, 100
    li t1, 100
    mulhu t2, t0, t1
    li t3, 0           # Upper bits should be 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 14 passed
    
    # MULHU test 2: Large values
    li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
    li t1, 0xFFFFFFFF  # Max unsigned 32-bit number
    mulhu t2, t0, t1
    li t3, 0xFFFFFFFE  # Upper 32 bits of 0xFFFFFFFE00000001
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 15 passed
    
    # MULHU test 3: Mixed values
    li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
    li t1, 2           # Small value
    mulhu t2, t0, t1
    li t3, 1           # Upper 32 bits of 0x1FFFFFFFE
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 16 passed
    
    # ==========================================
    # Division Instructions Tests
    # ==========================================
    
    # ---- DIV: Signed division ----
    
    # DIV test 1: Basic positive division
    li t0, 100
    li t1, 10
    div t2, t0, t1     # 100/10 = 10
    li t3, 10
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 17 passed
    
    # DIV test 2: Negative dividend
    li t0, -100
    li t1, 10
    div t2, t0, t1     # -100/10 = -10
    li t3, -10
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 18 passed
    
    # DIV test 3: Negative divisor
    li t0, 100
    li t1, -10
    div t2, t0, t1     # 100/-10 = -10
    li t3, -10
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 19 passed
    
    # DIV test 4: Negative dividend and divisor
    li t0, -100
    li t1, -10
    div t2, t0, t1     # -100/-10 = 10
    li t3, 10
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 20 passed
    
    # DIV test 5: Fraction result truncated toward zero
    li t0, 1234
    li t1, 1000
    div t2, t0, t1     # 1234/1000 = 1.234 truncated to 1
    li t3, 1
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 21 passed
    
    # DIV test 6: Negative fraction result truncated toward zero
    li t0, -1234
    li t1, 1000
    div t2, t0, t1     # -1234/1000 = -1.234 truncated to -1
    li t3, -1
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 22 passed
    
    # DIV test 7: Division by zero
    li t0, 100
    li t1, 0
    div t2, t0, t1     # Division by zero returns -1
    li t3, -1
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 23 passed
    
    # DIV test 8: Overflow case (most negative value divided by -1)
    li t0, 0x80000000  # Most negative 32-bit number (-2^31)
    li t1, -1
    div t2, t0, t1     # Should overflow and return same value
    li t3, 0x80000000
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 24 passed
    
    # DIV test 9: Dividend is zero
    li t0, 0
    li t1, 10
    div t2, t0, t1     # 0/10 = 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 25 passed
    
    # ---- DIVU: Unsigned division ----
    
    # DIVU test 1: Basic unsigned division
    li t0, 100
    li t1, 10
    divu t2, t0, t1    # 100/10 = 10 (unsigned)
    li t3, 10
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 26 passed
    
    # DIVU test 2: Large numbers
    li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
    li t1, 0x10000000  # Large divisor
    divu t2, t0, t1    # Should be 15 (0xF + remainder)
    li t3, 15
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 27 passed
    
    # DIVU test 3: "Negative" number (treated as large unsigned)
    li t0, 0x80000000  # Seen as 2^31 in unsigned
    li t1, 2
    divu t2, t0, t1    # 2^31/2 = 2^30
    li t3, 0x40000000  # 2^30
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 28 passed
    
    # DIVU test 4: Division by zero
    li t0, 100
    li t1, 0
    divu t2, t0, t1    # Division by zero returns all 1s
    li t3, -1          # All ones (0xFFFFFFFF)
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 29 passed
    
    # DIVU test 5: Dividend is zero
    li t0, 0
    li t1, 10
    divu t2, t0, t1    # 0/10 = 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 30 passed
    
    # DIVU test 6: Large value divided by maximum (should be 0)
    li t0, 0x00FFFFFF  # Smaller than max
    li t1, 0xFFFFFFFF  # Max unsigned
    divu t2, t0, t1    # Result should be 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 31 passed
    
    # ---- REM: Signed remainder ----
    
    # REM test 1: Basic positive remainder
    li t0, 102
    li t1, 10
    rem t2, t0, t1     # 102 % 10 = 2
    li t3, 2
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 32 passed
    
    # REM test 2: Negative dividend
    li t0, -102
    li t1, 10
    rem t2, t0, t1     # -102 % 10 = -2 (same sign as dividend)
    li t3, -2
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 33 passed
    
    # REM test 3: Negative divisor
    li t0, 102
    li t1, -10
    rem t2, t0, t1     # 102 % -10 = 2 (same sign as dividend)
    li t3, 2
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 34 passed
    
    # REM test 4: Negative dividend and divisor
    li t0, -102
    li t1, -10
    rem t2, t0, t1     # -102 % -10 = -2 (same sign as dividend)
    li t3, -2
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 35 passed
    
    # REM test 5: Zero remainder
    li t0, 100
    li t1, 10
    rem t2, t0, t1     # 100 % 10 = 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 36 passed
    
    # REM test 6: Division by zero
    li t0, 100
    li t1, 0
    rem t2, t0, t1     # Remainder by zero returns the dividend
    li t3, 100
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 37 passed
    
    # REM test 7: Overflow case (most negative divided by -1)
    li t0, 0x80000000  # Most negative 32-bit number
    li t1, -1
    rem t2, t0, t1     # Should be 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 38 passed
    
    # REM test 8: Dividend is zero
    li t0, 0
    li t1, 10
    rem t2, t0, t1     # 0 % 10 = 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 39 passed
    
    # ---- REMU: Unsigned remainder ----
    
    # REMU test 1: Basic unsigned remainder
    li t0, 102
    li t1, 10
    remu t2, t0, t1    # 102 % 10 = 2 (unsigned)
    li t3, 2
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 40 passed
    
    # REMU test 2: Large values
    li t0, 0xFFFFFFFF  # Max unsigned 32-bit number
    li t1, 0x10000000  # Large divisor
    remu t2, t0, t1    # Should be 0x0FFFFFFF (remainder)
    li t3, 0x0FFFFFFF
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 41 passed
    
    # REMU test 3: "Negative" number (treated as large unsigned)
    li t0, 0x80000005  # Would be negative in signed
    li t1, 4
    remu t2, t0, t1    # Should be 1
    li t3, 1
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 42 passed
    
    # REMU test 4: Remainder by zero
    li t0, 100
    li t1, 0
    remu t2, t0, t1    # Remainder by zero returns the dividend
    li t3, 100
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 43 passed
    
    # REMU test 5: Dividend is zero
    li t0, 0
    li t1, 10
    remu t2, t0, t1    # 0 % 10 = 0
    li t3, 0
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 44 passed
    
    # REMU test 6: Dividend smaller than divisor
    li t0, 3
    li t1, 10
    remu t2, t0, t1    # 3 % 10 = 3
    li t3, 3
    bne t2, t3, test_failed
    addi t6, t6, 1    # Test 45 passed

    # Success - all tests passed! Store the results
    j test_passed

# Trap handler
trap_handler:
    # Simple trap handler just for completeness
    csrr t0, mcause
    csrr t1, mepc
    addi t1, t1, 4    # Skip the faulting instruction
    csrw mepc, t1
    mret

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
test_result:
    .word 0    # Test number
    .word 0    # Success/failure indicator