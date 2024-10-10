// module up_counter_with_lock (
//     input clk,
//     input lock,
//     output reg [3:0] counter
// );

//     always @(posedge clk) begin
//         if (lock) begin
//             counter <= 4'b1111; // Set counter to 16 (4'b1111)
//         end else begin
//             counter <= counter + 1; // Increment counter
//         end
//     end

// endmodule

// module decoder (
//     input [3:0] a,
//     output reg [15:0] y
// );

//     always @(*) begin
//         case (a)
//             4'b0000: y = 16'b0000000000000001;
//             4'b0001: y = 16'b0000000000000010;
//             4'b0010: y = 16'b0000000000000100;
//             4'b0011: y = 16'b0000000000001000;
//             4'b0100: y = 16'b0000000000010000;
//             4'b0101: y = 16'b0000000000100000;
//             4'b0110: y = 16'b0000000001000000;
//             4'b0111: y = 16'b0000000010000000;
//             4'b1000: y = 16'b0000000100000000;
//             4'b1001: y = 16'b0000001000000000;
//             4'b1010: y = 16'b0000010000000000;
//             4'b1011: y = 16'b0000100000000000;
//             4'b1100: y = 16'b0001000000000000;
//             4'b1101: y = 16'b0010000000000000;
//             4'b1110: y = 16'b0100000000000000;
//             4'b1111: y = 16'b1000000000000000;
//             default: y = 16'b0000000000000000;
//         endcase
//     end

// endmodule


// module bit_selector (
//     // input [15:0] a,
//     // input [15:0] b,

//     input flag,
//     input lock,
//     input [15:0] a,
//     output reg y
// );
    
//     wire [3:0] count;
//     wire [15:0] decoded;
//     reg [15:0] and_result;
//     integer i;

//     up_counter_with_lock counter(flag,lock,count);
//     decoder decoder_inst(count,decoded);
    
//     always @(*) begin
//         and_result = decoded & a; // Perform bitwise AND
//         y = 0;
//         for (i = 0; i < 16; i = i + 1) begin
//             y = y | and_result[i]; // OR each bit
//         end
//     end

    

// endmodule

// module tb_bit_selector;

//     reg flag;
//     reg lock;
//     reg [15:0] a;
//     wire y;

//     // Instantiate the bit_selector module
//     bit_selector uut (
//         .flag(flag),
//         .lock(lock),
//         .a(a),
//         .y(y)
//     );

//     // Clock generation for flag
//     initial begin
//         flag = 0;
//         forever #5 flag = ~flag; // 10ns period clock
//     end

//     // Test sequence
//     initial begin
//         // Monitor the output
//         $monitor("Time: %0t | flag: %b | lock: %b | a: %b | y: %b", $time, flag, lock, a, y);

//         // Initialize signals
//         lock = 0;
//         a = 16'b0000000000000000; #10;
//         a = 16'b0000000000000001; #10;
//         a = 16'b0000000000000010; #10;
//         a = 16'b0000000000000100; #10;
//         a = 16'b0000000000001000; #10;
//         a = 16'b0000000000010000; #10;
//         a = 16'b0000000000100000; #10;
//         a = 16'b0000000001000000; #10;
//         a = 16'b0000000010000000; #10;
//         a = 16'b0000000100000000; #10;
//         a = 16'b0000001000000000; #10;
//         a = 16'b0000010000000000; #10;
//         a = 16'b0000100000000000; #10;
//         a = 16'b0001000000000000; #10;
//         a = 16'b0010000000000000; #10;
//         a = 16'b0100000000000000; #10;
//         a = 16'b1000000000000000; #10;

//         lock = 1; #10;
//         lock = 0; #50;

//         $finish;
//     end

// endmodule


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