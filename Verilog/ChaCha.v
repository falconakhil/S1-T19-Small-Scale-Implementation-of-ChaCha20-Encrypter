//quarter round generator module
module qrg (
    input A, B, C, D,         // 4 inputs
    output reg a, b, c, d     // 4 outputs
);

    always @(*) begin
        case ({A, B, C, D})
            4'b0000: {a, b, c, d} = 4'b0000;
            4'b0001: {a, b, c, d} = 4'b1010;
            4'b0010: {a, b, c, d} = 4'b1101;
            4'b0011: {a, b, c, d} = 4'b0111;
            4'b0100: {a, b, c, d} = 4'b1110;
            4'b0101: {a, b, c, d} = 4'b0100;
            4'b0110: {a, b, c, d} = 4'b0011;
            4'b0111: {a, b, c, d} = 4'b1001;
            4'b1000: {a, b, c, d} = 4'b0101;
            4'b1001: {a, b, c, d} = 4'b1111;
            4'b1010: {a, b, c, d} = 4'b1000;
            4'b1011: {a, b, c, d} = 4'b0010;
            4'b1100: {a, b, c, d} = 4'b1011;
            4'b1101: {a, b, c, d} = 4'b0001;
            4'b1110: {a, b, c, d} = 4'b0110;
            4'b1111: {a, b, c, d} = 4'b1100;
        endcase
    end
endmodule
//2-bit counter module
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
//key stream generator module
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
//plain text input module
module plain_text (
    input wire plain_text_input1,       // First input bit
    input wire plain_text_input2,       // Second input bit
    output wire flag,      // Flag output, set to 1 if any input bit is 1
    output wire bit_value  // Output the bit value that is set
);

    // Set the flag if any of the input bits is 1
    or(flag,plain_text_input1,plain_text_input2);

    // Output the bit value that is set (1 if bit1 is set, otherwise 0)
    assign bit_value = plain_text_input1 ? 1'b1 : 1'b0;

endmodule
//bit selector for final output
module bit_selector (
    input [15:0] data_in,     // 16-bit input data
    input [3:0] clock_in,     // 4-bit input clock
    input lock,               // Lock signal
    output reg out            // Selected bit output
);

    // Internal signals
    reg [3:0] effective_clock;    // Clock value after lock logic
    reg [15:0] decoder_out;

    // Lock logic
    always @(*) begin
        effective_clock = lock ? 4'b1111 : clock_in;
    end

    // Decoder logic
    always @(*) begin
        decoder_out = 16'b0000_0000_0000_0001 << effective_clock;
    end

    // Reversed multiplexer logic
    always @(*) begin
        case (effective_clock)
            4'b0000: out = data_in[15];  // Clock 0 selects last bit
            4'b0001: out = data_in[14];  // Clock 1 selects second-to-last bit
            4'b0010: out = data_in[13];
            4'b0011: out = data_in[12];
            4'b0100: out = data_in[11];
            4'b0101: out = data_in[10];
            4'b0110: out = data_in[9];
            4'b0111: out = data_in[8];
            4'b1000: out = data_in[7];
            4'b1001: out = data_in[6];
            4'b1010: out = data_in[5];
            4'b1011: out = data_in[4];
            4'b1100: out = data_in[3];
            4'b1101: out = data_in[2];
            4'b1110: out = data_in[1];
            4'b1111: out = data_in[0];  // Clock 15 selects first bit
            default: out = 1'b0;
        endcase
    end

endmodule
//main module
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
    wire [3:0] constant = 4'b1011;

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

    // Instantiate the bit selector
    bit_selector bit_selector_uut (
        .data_in(ksg_combined_output),
        .clock_in({counter_output, 2'b00}),  // Use counter output as part of clock input
        .lock(lock),
        .out(bit_selector_output)
    );

    // XOR the bit selector output with the plain-text bit value
    assign final_output = bit_selector_output ^ plain_text_bit_value;

endmodule