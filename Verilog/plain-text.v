module PlainTextInput (
    input wire bit1,       // First input bit
    input wire bit2,       // Second input bit
    output wire flag,      // Flag output, set to 1 if any input bit is 1
    output wire bit_value  // Output the bit value that is set
);

    // Set the flag if any of the input bits is 1
    assign flag = bit1 | bit2;

    // Output the bit value that is set (1 if bit1 is set, otherwise 0)
    assign bit_value = bit1 ? 1'b1 : 1'b0;

endmodule