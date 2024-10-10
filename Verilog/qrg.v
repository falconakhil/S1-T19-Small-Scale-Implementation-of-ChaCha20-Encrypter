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

// Testbench
module qrg_tb;
    reg A, B, C, D;
    wire a, b, c, d;

    // Instantiate the truth table module
    qrg uut (
        .A(A), .B(B), .C(C), .D(D),
        .a(a), .b(b), .c(c), .d(d)
    );

    initial begin
        $dumpfile("qrg.vcd");
        $dumpvars(0, qrg_tb);

        // Test all 16 input combinations
        {A, B, C, D} = 4'b0000; #10;
        {A, B, C, D} = 4'b0001; #10;
        {A, B, C, D} = 4'b0010; #10;
        {A, B, C, D} = 4'b0011; #10;
        {A, B, C, D} = 4'b0100; #10;
        {A, B, C, D} = 4'b0101; #10;
        {A, B, C, D} = 4'b0110; #10;
        {A, B, C, D} = 4'b0111; #10;
        {A, B, C, D} = 4'b1000; #10;
        {A, B, C, D} = 4'b1001; #10;
        {A, B, C, D} = 4'b1010; #10;
        {A, B, C, D} = 4'b1011; #10;
        {A, B, C, D} = 4'b1100; #10;
        {A, B, C, D} = 4'b1101; #10;
        {A, B, C, D} = 4'b1110; #10;
        {A, B, C, D} = 4'b1111; #10;

        $finish;
    end

    // Monitor changes
    initial
        $monitor("Time=%0t A=%b B=%b C=%b D=%b | a=%b b=%b c=%b d=%b",
                 $time, A, B, C, D, a, b, c, d);
endmodule
