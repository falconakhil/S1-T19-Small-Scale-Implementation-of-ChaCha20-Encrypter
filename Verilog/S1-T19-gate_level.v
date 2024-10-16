module qrg(A,B,C,D,a,b,c,d);

    input A,B,C,D;
    output a,b,c,d;
    wire notA,notB, notC, notD;
    wire w1, w2, w3, w4;

    // Inverters
    not (notB, B);
    not (notC, C);
    not (notD, D);
    not (notA, A);

    // Logic for output a
    and (w1, notB, notC, D);      // ~B ~C D
    and (w2, notB, C, notD);      // ~B C ~D
    and (w3, B, notC, notD);      // B ~C ~D
    and (w4, B, C, D);            // B C D
    or  (a, w1, w2, w3, w4);      // Combine all


    
    wire w5, w6, w7, w8;

    

    // Logic for output b
    and (w5, notA, notB, C);      // ~A ~B C
    and (w6, notA, B, notC);      // ~A B ~C
    and (w7, A, notB, notC);      // A ~B ~C
    and (w8, A, B, C);            // A B C
    or  (b, w5, w6, w7, w8);      // Combine all


    xor(c,B,D);



    xor(d,A,C);
endmodule
module two_bit_counter (
    input wire clk,         // Clock input
    input wire reset,       // Asynchronous reset input
    input wire [1:0] init_value, // Initial value input
    input wire lock,        // Lock input to set initial value
    output reg [1:0] count  // 2-bit counter output
);

    always @(posedge clk or posedge reset or posedge lock) begin
        if (reset) begin
            count <= 2'b00;  // Reset counter to 0
        end else if (lock) begin
            count <= init_value;  // Set counter to initial value
        end else begin
            count <= count + 1;  // Increment counter
        end
    end
endmodule
module ksg (
    input [3:0] constant,
    input [7:0] key,
    input [1:0] counter,
    input [1:0] nonce,
    output [3:0] final_out1,
    output [3:0] final_out2,
    output [3:0] final_out3,
    output [3:0] final_out4
);
    wire [3:0] qrg_out1, qrg_out2, qrg_out3, qrg_out4;

    // First round of qrg instances with reversed input bits
    qrg qrg1 (
        .A(constant[3]), // Reversed
        .B(key[7]),      // Reversed
        .C(key[6]),      // Reversed
        .D(counter[1]),  // Reversed
        .a(qrg_out1[0]),
        .b(qrg_out1[1]),
        .c(qrg_out1[2]),
        .d(qrg_out1[3])
    );

    qrg qrg2 (
        .A(constant[2]), // Reversed
        .B(key[5]),      // Reversed
        .C(key[4]),      // Reversed
        .D(counter[0]),  // Reversed
        .a(qrg_out2[0]),
        .b(qrg_out2[1]),
        .c(qrg_out2[2]),
        .d(qrg_out2[3])
    );

    qrg qrg3 (
        .A(constant[1]), // Reversed
        .B(key[3]),      // Reversed
        .C(key[2]),      // Reversed
        .D(nonce[1]),    // Reversed
        .a(qrg_out3[0]),
        .b(qrg_out3[1]),
        .c(qrg_out3[2]),
        .d(qrg_out3[3])
    );

    qrg qrg4 (
        .A(constant[0]), // Reversed
        .B(key[1]),      // Reversed
        .C(key[0]),      // Reversed
        .D(nonce[0]),    // Reversed
        .a(qrg_out4[0]),
        .b(qrg_out4[1]),
        .c(qrg_out4[2]),
        .d(qrg_out4[3])
    );

    // Second round of qrg instances with cyclic input bits
    qrg qrg5 (
        .A(qrg_out1[0]),
        .B(qrg_out2[1]),
        .C(qrg_out3[2]),
        .D(qrg_out4[3]),
        .a(final_out1[3]),
        .b(final_out1[2]),
        .c(final_out1[1]),
        .d(final_out1[0])
    );

    qrg qrg6 (
        .A(qrg_out1[1]),
        .B(qrg_out2[2]),
        .C(qrg_out3[3]),
        .D(qrg_out4[0]),
        .a(final_out2[3]),
        .b(final_out2[2]),
        .c(final_out2[1]),
        .d(final_out2[0])
    );

    qrg qrg7 (
        .A(qrg_out1[2]),
        .B(qrg_out2[3]),
        .C(qrg_out3[0]),
        .D(qrg_out4[1]),
        .a(final_out3[3]),
        .b(final_out3[2]),
        .c(final_out3[1]),
        .d(final_out3[0])
    );

    qrg qrg8 (
        .A(qrg_out1[3]),
        .B(qrg_out2[0]),
        .C(qrg_out3[1]),
        .D(qrg_out4[2]),
        .a(final_out4[3]),
        .b(final_out4[2]),
        .c(final_out4[1]),
        .d(final_out4[0])
    );
endmodule
module plain_text (
    input wire plain_text_input1,       // First input bit
    input wire plain_text_input2,       // Second input bit
    output wire flag,      // Flag output, set to 1 if any input bit is 1
    output wire bit_value  // Output the bit value that is set
);

    // Set the flag if any of the input bits is 1
    or(flag,plain_text_input1,plain_text_input2);

    // Output the bit value that is set (1 if bit1 is set, otherwise 0)
    and(bit_value,1'b1,plain_text_input1);
endmodule
module four_counter (
    input clk,                // Clock input
    input reset,              // Reset input
    input lock,               // Lock signal
    output reg [3:0] count    // 4-bit counter output
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;  // Reset counter to 0
        end else if (lock) begin
            count <= 4'b1111;  // Set counter to 16 (4'b1111)
        end else begin
            count <= count + 1; // Increment counter
        end
    end
endmodule
module four_to_sixteen_decoder (
    input [3:0] in,       // 4-bit input
    output [15:0] out     // 16-bit output
);

    wire [3:0] not_in; // Inverted inputs

    // Invert inputs
    not (not_in[0], in[0]);
    not (not_in[1], in[1]);
    not (not_in[2], in[2]);
    not (not_in[3], in[3]);

    // Generate outputs using AND gates (output reversed)
    and (out[0], in[3], in[2], in[1], in[0]);          // 1111 -> 0
    and (out[1], in[3], in[2], in[1], not_in[0]);     // 1110 -> 1
    and (out[2], in[3], in[2], not_in[1], in[0]);     // 1101 -> 2
    and (out[3], in[3], in[2], not_in[1], not_in[0]); // 1100 -> 3
    and (out[4], in[3], not_in[2], in[1], in[0]);     // 1011 -> 4
    and (out[5], in[3], not_in[2], in[1], not_in[0]); // 1010 -> 5
    and (out[6], in[3], not_in[2], not_in[1], in[0]); // 1001 -> 6
    and (out[7], in[3], not_in[2], not_in[1], not_in[0]); // 1000 -> 7
    and (out[8], not_in[3], in[2], in[1], in[0]);     // 0111 -> 8
    and (out[9], not_in[3], in[2], in[1], not_in[0]); // 0110 -> 9
    and (out[10], not_in[3], in[2], not_in[1], in[0]); // 0101 -> 10
    and (out[11], not_in[3], in[2], not_in[1], not_in[0]); // 0100 -> 11
    and (out[12], not_in[3], not_in[2], in[1], in[0]); // 0011 -> 12
    and (out[13], not_in[3], not_in[2], in[1], not_in[0]); // 0010 -> 13
    and (out[14], not_in[3], not_in[2], not_in[1], in[0]); // 0001 -> 14
    and (out[15], not_in[3], not_in[2], not_in[1], not_in[0]); // 0000 -> 15

endmodule

module selector (
    input [15:0] data_in, // 16-bit input data
    input [15:0] select,   // 16-bit select from the decoder
    output out             // Selected bit output
);

    wire and0, and1, and2, and3, and4, and5, and6, and7;
    wire and8, and9, and10, and11, and12, and13, and14, and15;

    // Use AND gates to select the appropriate bit
    and (and0, data_in[0], select[0]);
    and (and1, data_in[1], select[1]);
    and (and2, data_in[2], select[2]);
    and (and3, data_in[3], select[3]);
    and (and4, data_in[4], select[4]);
    and (and5, data_in[5], select[5]);
    and (and6, data_in[6], select[6]);
    and (and7, data_in[7], select[7]);
    and (and8, data_in[8], select[8]);
    and (and9, data_in[9], select[9]);
    and (and10, data_in[10], select[10]);
    and (and11, data_in[11], select[11]);
    and (and12, data_in[12], select[12]);
    and (and13, data_in[13], select[13]);
    and (and14, data_in[14], select[14]);
    and (and15, data_in[15], select[15]);

    // OR the selected bits
    or (out, and0, and1, and2, and3, and4, and5, and6, and7,
             and8, and9, and10, and11, and12, and13, and14, and15);

endmodule

module bit_selector (
    input [3:0] select,     // Selector input for the decoder
    input [15:0] data,      // 16-bit input data
    output selected_bit      // Selected bit output
);

    wire [15:0] decoder_out;

    // Instantiate the decoder
    four_to_sixteen_decoder decoder (
        .in(select),
        .out(decoder_out)
    );

    // Instantiate the bit selector
    selector s (
        .data_in(data),
        .select(decoder_out),
        .out(selected_bit)
    );

endmodule
module main (
    input wire clk,
    input wire reset,
    input wire [7:0] key,
    input wire [1:0] nonce,
    input wire  plain_text_input1,
    input wire plain_text_input2,
    input wire [1:0] init_value,
    input wire lock,  // Lock input for both counter and bit selector
    output wire final_output
);

    // Internal signals
    wire [1:0] counter_output;
    wire [3:0] ksg_output1, ksg_output2, ksg_output3, ksg_output4;
    wire [3:0] constant = 4'b1101;

    wire bit_selector_output;
    wire plain_text_flag;
    wire plain_text_bit_value;

    // Instantiate the two_bit_counter
    two_bit_counter counter_uut (
        .clk(plain_text_flag),
        .reset(reset),
        .init_value(init_value),
        .lock(lock),
        .count(counter_output)
    );

    // Instantiate the ksg module
    ksg ksg_uut (
        .constant(constant),
        .key(key),
        .counter(counter_output),
        .nonce(nonce),
        .final_out1(ksg_output1),
        .final_out2(ksg_output2),
        .final_out3(ksg_output3),
        .final_out4(ksg_output4)
    );

    // Instantiate the plain-text input module
    plain_text plain_text_uut (
        .plain_text_input1(plain_text_input1),
        .plain_text_input2(plain_text_input2),
        .flag(plain_text_flag),
        .bit_value(plain_text_bit_value)
    );

    // Concatenate ksg outputs to form a 16-bit input for bit selector
    wire [15:0] ksg_combined_output = {ksg_output1, ksg_output2, ksg_output3, ksg_output4};
    wire [3:0] four_out;

    four_counter counter_4 (
        .clk(plain_text_flag),
        .reset(reset),
        .lock(lock),
        .count(four_out)
    );

    // Instantiate the bit selector
    bit_selector bit_selector_uut (
        .data(ksg_combined_output),
        .select(four_out),  // Use counter output as part of clock input
        // .lock(lock),
        .selected_bit(bit_selector_output)
    );

    // XOR the bit selector output with the plain-text bit value
    assign final_output = bit_selector_output ^ plain_text_bit_value;
endmodule