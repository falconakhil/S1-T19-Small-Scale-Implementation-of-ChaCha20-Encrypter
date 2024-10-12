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

// Testbench
module bit_selector_tb;
    reg [15:0] data_in;
    reg [3:0] clock_in; // Updated to 4-bit clock
    reg lock;
    wire out;

    // Instantiate the bit selector module
    bit_selector uut (
        .data_in(data_in),
        .clock_in(clock_in),
        .lock(lock),
        .out(out)
    );

    initial begin
        $dumpfile("bit_selector.vcd");
        $dumpvars(0, bit_selector_tb);

        // Initialize inputs
        data_in = 16'b1010_1100_1111_0000;  // Test pattern
        lock = 0;  // Start with lock disabled

        // Test normal operation (lock disabled)
        $display("Testing normal operation (lock disabled):");
        $display("Data_in = %b", data_in);
        
        clock_in = 4'b0000; #10;  // Should select bit 15
        $display("Clock = 0000, Selected bit: %b (should be bit 15)", out);
        
        clock_in = 4'b1001; #10;  // Should select bit 14
        $display("Clock = 1001, Selected bit: %b (should be bit 14)", out);
        
        clock_in = 4'b0010; #10;  // Should select bit 13
        $display("Clock = 0010, Selected bit: %b (should be bit 13)", out);
        
        clock_in = 4'b0011; #10;  // Should select bit 12
        $display("Clock = 0011, Selected bit: %b (should be bit 12)", out);

        // Test with lock enabled (should select bit 0)
        $display("\nTesting with lock enabled (should always select bit 0):");
        lock = 1;
        clock_in = 4'b0000; #10;
        $display("Lock enabled, Clock = 0000, Selected bit: %b (should be bit 0)", out);
        
        clock_in = 4'b0011; #10;
        $display("Lock enabled, Clock = 0011, Selected bit: %b (should be bit 0)", out);

        // Test with different data pattern
        $display("\nTesting with different data pattern:");
        lock = 0;
        data_in = 16'b0101_0011_0000_1111;
        $display("New data_in = %b", data_in);
        
        clock_in = 4'b0000; #10;  // Should select bit 15
        $display("Clock = 0000, Selected bit: %b (should be bit 15)", out);
        
        clock_in = 4'b1111; #10;  // Should select bit 0
        $display("Clock = 1111, Selected bit: %b (should be bit 0)", out);

        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t data_in=%b clock_in=%b lock=%b effective_clock=%b selected_bit=%b",
                 $time, data_in, clock_in, lock, uut.effective_clock, out);
    end
endmodule