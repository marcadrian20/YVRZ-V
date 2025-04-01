.section .text
.globl _start

_start:
    # Initialize stack pointer to end of DMEM
    li sp, 0x3FFC    # End of DMEM (4095*4 = 16380 = 0x3FFC)

    # Initialize a test counter in t6
    li t6, 0

    # ==========================================
    # ZICSR Instructions Tests
    # ==========================================
    
    # Test 1: CSRRW - Read and write a CSR
    li t0, 0xABCDEF01            # Prepare test value
    csrrw t1, mscratch, t0       # Write t0 to mscratch, read previous value to t1
    csrrw t2, mscratch, zero     # Read mscratch to t2, write 0
    bne t2, t0, test_failed      # t2 should equal t0
    addi t6, t6, 1               # Test 1 passed
    
    # Test 2: CSRRS - Read and set bits in a CSR
    li t0, 0                     # Prepare zero value
    csrrw t1, mscratch, t0       # Zero out mscratch
    li t0, 0x0F0F0F0F            # Prepare bit pattern
    csrrs t1, mscratch, t0       # Set bits in t0, read previous value (0)
    bne t1, zero, test_failed    # t1 should be 0, not t0
    csrrs t2, mscratch, zero     # Read without modifying
    bne t2, t0, test_failed      # t2 should equal t0
    addi t6, t6, 1               # Test 2 passed
    
    # Test 3: CSRRC - Read and clear bits in a CSR
    li t0, 0xFFFFFFFF            # Prepare all-ones value
    csrrw t1, mscratch, t0       # Set all bits in mscratch
    li t0, 0x0F0F0F0F            # Prepare bit pattern to clear
    csrrc t1, mscratch, t0       # Clear bits in t0, read previous value
    li t3, 0xFFFFFFFF            # Expected value after clearing
    bne t1, t3, test_failed      # t1 should equal initial value 0xFFFFFFFF
    li t2, 0xF0F0F0F0            # Expected value after clearing
    csrrc t3, mscratch, zero     # Read without modifying
    bne t3, t2, test_failed      # t3 should equal t2
    addi t6, t6, 1               # Test 3 passed
    
    # Test 4: CSRRWI - Write immediate value to CSR
    csrrwi t0, mscratch, 15      # Write immediate 15 to mscratch
    csrr t1, mscratch            # Read mscratch to t1
    li t2, 15
    bne t1, t2, test_failed      # t1 should be 15
    addi t6, t6, 1               # Test 4 passed
    
    # Test 5: CSRRSI - Set bits immediate
    csrrw t0, mscratch, zero     # Zero out mscratch
    csrrsi t0, mscratch, 10      # Set bits 1 and 3 (value 10)
    csrr t1, mscratch            # Read mscratch to t1
    li t2, 10
    bne t1, t2, test_failed      # t1 should be 10
    addi t6, t6, 1               # Test 5 passed
    
    # Test 6: CSRRCI - Clear bits immediate
    li t0, 0xFFFFFFFF
    csrrw t1, mscratch, t0       # Set all bits in mscratch
    csrrci t0, mscratch, 10      # Clear bits 1 and 3 (value 10)
    csrr t1, mscratch            # Read mscratch to t1
    li t2, 0xFFFFFFF5            # Expected value after clearing bits 1 and 3
    bne t1, t2, test_failed      # t1 should be t2
    addi t6, t6, 1               # Test 6 passed
    
    # Test 7: CSR read/write to multiple CSRs
    # First, save original mtvec value to restore later
    csrr s0, mtvec
    
    # Test mtvec
    li t0, 0x12345678
    csrrw t1, mtvec, t0          # Write t0 to mtvec
    csrr t2, mtvec               # Read back from mtvec
    bne t2, t0, test_failed      # Should get back what we wrote
    
    # Restore original mtvec
    csrrw t0, mtvec, s0
    addi t6, t6, 1               # Test 7 passed
    
    # Test 8: mepc read/write
    li t0, 0x87654321
    csrrw t1, mepc, t0           # Write to mepc
    csrr t2, mepc                # Read back
    bne t2, t0, test_failed      # Verify read matches write
    addi t6, t6, 1               # Test 8 passed
    
    # Test 9: mcause read/write
    li t0, 11                    # ECALL from M-mode cause
    csrrw t1, mcause, t0         # Write to mcause
    csrr t2, mcause              # Read back
    bne t2, t0, test_failed      # Verify read matches write
    addi t6, t6, 1               # Test 9 passed
    
    # Test 10: CSR Read-Modify-Write patterns
    # Zero out mscratch
    csrrw zero, mscratch, zero
    
    # Set alternating bit pattern
    li t0, 0xAAAAAAAA
    csrrs zero, mscratch, t0     # Set without reading
    
    # Set additional bits with different pattern
    li t0, 0x55555555 
    csrrs t1, mscratch, t0       # Set more bits, read previous value
    li t2, 0xAAAAAAAA            # Previous value
    bne t1, t2, test_failed
    
    # Read final pattern
    csrr t1, mscratch
    li t2, 0xFFFFFFFF            # All bits should be set now
    bne t1, t2, test_failed
    addi t6, t6, 1               # Test 10 passed
    
    # Success - all tests passed! Store the results
    j test_passed

test_failed:
    # Store the failed test number at test_result
    la t0, test_result
    sw t6, 0(t0)
    li t1, 0xFFFFFFFF            # Failure indicator
    sw t1, 4(t0)
    # Also store at the very end of DMEM for easy checking
    li t0, 0x3FF8                # Last two words in DMEM
    sw t6, 0(t0)
    sw t1, 4(t0)
    j end

test_passed:
    # Store the success indicator at test_result
    la t0, test_result
    sw t6, 0(t0)
    li t1, 0xAA55AA55            # Success indicator 
    sw t1, 4(t0)
    # Also store at the very end of DMEM for easy checking
    li t0, 0x3FF8                # Last two words in DMEM
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
