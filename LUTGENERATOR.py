def generate_systemverilog_module():
    """Generate a SystemVerilog module implementing the LUT without using pandas"""
    # Manually input the values from the table as tuples: (b, p_min, p_max, q)
    data = [
        # b, p_min, p_max, q
        # First column of the table
        (8, -12, -7, -2),
        (8, -6, -3, -1),
        (8, -2, 1, 0),
        (8, 2, 5, 1),
        (8, 6, 11, 2),
        
        (9, -14, -8, -2),
        (9, -7, -3, -1),
        (9, -3, 2, 0),
        (9, 2, 6, 1),
        (9, 7, 13, 2),
        
        (10, -15, -9, -2),
        (10, -8, -3, -1),
        (10, -3, 2, 0),
        (10, 2, 7, 1),
        (10, 8, 14, 2),
        
        (11, -16, -9, -2),
        (11, -9, -3, -1),
        (11, -3, 2, 0),
        (11, 2, 8, 1),
        (11, 8, 15, 2),
        
        # Second column of the table
        (12, -18, -10, -2),
        (12, -10, -4, -1),
        (12, -4, 3, 0),
        (12, 3, 9, 1),
        (12, 9, 17, 2),
        
        (13, -19, -11, -2),
        (13, -10, -4, -1),
        (13, -4, 3, 0),
        (13, 3, 9, 1),
        (13, 10, 18, 2),
        
        (14, -20, -11, -2),
        (14, -11, -4, -1),
        (14, -4, 3, 0),
        (14, 3, 10, 1),
        (14, 10, 19, 2),
        
        (15, -22, -12, -2),
        (15, -12, -4, -1),
        (15, -5, 4, 0),
        (15, 3, 11, 1),
        (15, 11, 21, 2)
    ]
    
    # Start building the SystemVerilog module
    sv_module = """
// Division LUT module for normalized division with range-based implementation
// Input: b (4 MSB bits of normalized divisor in decimal form)
//        p (6 MSB bits of partial reminder in decimal form)
// Output: q (quotient digit)
module SRTlut(
    input  logic [3:0] b,      // 4 MSB bits of normalized divisor (8-15)
    input  logic signed [5:0] p,  // 6 MSB bits of partial reminder
    output logic signed [2:0] q   // quotient digit (-2 to 2)
);

    // LUT implementation using combinational logic with ranges
    // Priority: if there are overlapping ranges, 0 is selected over other digits
    always_comb begin
        // Default value
        q = 'b0;
        
        case(b)
"""
    
    # Group data by b values for cleaner case statement
    b_values = sorted(set(row[0] for row in data))
    
    for b_val in b_values:
        sv_module += f"            {b_val}: begin\n"
        
        # Get all rows for this b value
        b_rows = [row for row in data if row[0] == b_val]
        
        # First handle the zero cases with highest priority
        zero_rows = [row for row in b_rows if row[3] == 0]
        for row in zero_rows:
            _, p_min, p_max, _ = row
            sv_module += f"                if (p >= {p_min} && p <= {p_max}) q = 0;\n"
        
        # Then handle negative digits
        neg_rows = [row for row in b_rows if row[3] < 0]
        for row in neg_rows:
            _, p_min, p_max, q_val = row
            # Exclude ranges that overlap with the zero case
            ranges_to_exclude = []
            for zero_row in zero_rows:
                _, zero_min, zero_max, _ = zero_row
                # If there's overlap, adjust the range
                if not (p_max < zero_min or p_min > zero_max):
                    if p_min < zero_min:
                        ranges_to_exclude.append((p_min, zero_min - 1))
                    if p_max > zero_max:
                        ranges_to_exclude.append((zero_max + 1, p_max))
                else:
                    ranges_to_exclude.append((p_min, p_max))
            
            # Add the non-overlapping conditions
            for p_range_min, p_range_max in ranges_to_exclude:
                if p_range_min <= p_range_max:  # Ensure valid range
                    sv_module += f"                else if (p >= {p_range_min} && p <= {p_range_max}) q = {q_val};\n"
        
        # Finally, handle positive digits
        pos_rows = [row for row in b_rows if row[3] > 0]
        for row in pos_rows:
            _, p_min, p_max, q_val = row
            # Exclude ranges that overlap with the zero case
            ranges_to_exclude = []
            for zero_row in zero_rows:
                _, zero_min, zero_max, _ = zero_row
                # If there's overlap, adjust the range
                if not (p_max < zero_min or p_min > zero_max):
                    if p_min < zero_min:
                        ranges_to_exclude.append((p_min, zero_min - 1))
                    if p_max > zero_max:
                        ranges_to_exclude.append((zero_max + 1, p_max))
                else:
                    ranges_to_exclude.append((p_min, p_max))
            
            # Add the non-overlapping conditions
            for p_range_min, p_range_max in ranges_to_exclude:
                if p_range_min <= p_range_max:  # Ensure valid range
                    sv_module += f"                else if (p >= {p_range_min} && p <= {p_range_max}) q = {q_val};\n"
        
        sv_module += "            end\n\n"
    
    # Complete the module
    sv_module += """            default: q = 'b0; // Default for invalid b
        endcase
    end
    
endmodule
"""
    
    return sv_module

# Main execution
if __name__ == "__main__":
    # Generate a SystemVerilog module using ranges
    sv_code = generate_systemverilog_module()
    print("SystemVerilog Module (Range-Based Implementation):")
    print(sv_code)
    
    # Write the module to a file
    with open("SRTlut.sv", "w") as f:
        f.write(sv_code)
    print("\nSystemVerilog module written to 'SRTlut.sv'")