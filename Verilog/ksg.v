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

module ksg_tb;
    reg [3:0] constant;
    reg [7:0] key;
    reg [1:0] counter;
    reg [1:0] nonce;
    wire [3:0] final_out1;
    wire [3:0] final_out2;
    wire [3:0] final_out3;
    wire [3:0] final_out4;

    // Instantiate the ksg module
    ksg uut (
        .constant(constant),
        .key(key),
        .counter(counter),
        .nonce(nonce),
        .final_out1(final_out1),
        .final_out2(final_out2),
        .final_out3(final_out3),
        .final_out4(final_out4)
    );

    initial begin
        // Initialize inputs
        constant = 4'b0000;
        key = 8'b00000000;
        counter = 2'b00;
        nonce = 2'b00;

        // Dump waveform data
        $dumpfile("ksg_tb.vcd");
        $dumpvars(0, ksg_tb);

        // Apply test vectors
        #10 constant = 4'b1010; key = 8'b11001100; counter = 2'b01; nonce = 2'b10;
        #10 constant = 4'b0101; key = 8'b00110011; counter = 2'b10; nonce = 2'b01;
        #10 constant = 4'b1111; key = 8'b11110000; counter = 2'b11; nonce = 2'b11;
        #10 constant = 4'b0000; key = 8'b00001111; counter = 2'b00; nonce = 2'b00;

        // Finish simulation
        #10 $finish;
    end

    initial begin
        // Monitor the outputs
        $monitor("At time %t, constant = %b, key = %b, counter = %b, nonce = %b, final_out1 = %b, final_out2 = %b, final_out3 = %b, final_out4 = %b",
                 $time, constant, key, counter, nonce, final_out1, final_out2, final_out3, final_out4);
    end
endmodule