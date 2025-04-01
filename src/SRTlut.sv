
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
            8: begin
                if (p >= -2 && p <= 1) q = 0;
                else if (p >= -12 && p <= -7) q = -2;
                else if (p >= -6 && p <= -3) q = -1;
                else if (p >= 2 && p <= 5) q = 1;
                else if (p >= 6 && p <= 11) q = 2;
            end
//so it begins
            9: begin
                if (p >= -3 && p <= 2) q = 0;
                else if (p >= -14 && p <= -8) q = -2;
                else if (p >= -7 && p <= -4) q = -1;
                else if (p >= 3 && p <= 6) q = 1;
                else if (p >= 7 && p <= 13) q = 2;
            end

            10: begin
                if (p >= -3 && p <= 2) q = 0;
                else if (p >= -15 && p <= -9) q = -2;
                else if (p >= -8 && p <= -4) q = -1;
                else if (p >= 3 && p <= 7) q = 1;
                else if (p >= 8 && p <= 14) q = 2;
            end

            11: begin
                if (p >= -3 && p <= 2) q = 0;
                else if (p >= -16 && p <= -9) q = -2;
                else if (p >= -9 && p <= -4) q = -1;
                else if (p >= 3 && p <= 8) q = 1;
                else if (p >= 8 && p <= 15) q = 2;
            end

            12: begin
                if (p >= -4 && p <= 3) q = 0;
                else if (p >= -18 && p <= -10) q = -2;
                else if (p >= -10 && p <= -5) q = -1;
                else if (p >= 4 && p <= 9) q = 1;
                else if (p >= 9 && p <= 17) q = 2;
            end

            13: begin
                if (p >= -4 && p <= 3) q = 0;
                else if (p >= -19 && p <= -11) q = -2;
                else if (p >= -10 && p <= -5) q = -1;
                else if (p >= 4 && p <= 9) q = 1;
                else if (p >= 10 && p <= 18) q = 2;
            end

            14: begin
                if (p >= -4 && p <= 3) q = 0;
                else if (p >= -20 && p <= -11) q = -2;
                else if (p >= -11 && p <= -5) q = -1;
                else if (p >= 4 && p <= 10) q = 1;
                else if (p >= 10 && p <= 19) q = 2;
            end

            15: begin
                if (p >= -5 && p <= 4) q = 0;
                else if (p >= -22 && p <= -12) q = -2;
                else if (p >= -12 && p <= -6) q = -1;
                else if (p >= 5 && p <= 11) q = 1;
                else if (p >= 11 && p <= 21) q = 2;
            end

            default: q = 'b0; // Default for invalid b
        endcase
    end
    
endmodule
