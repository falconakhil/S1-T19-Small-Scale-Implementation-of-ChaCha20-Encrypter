// module two_bit_counter (
//     input wire clk,         // Clock input
//     input wire reset,       // Asynchronous reset input
//     input wire set_to_0,    // Asynchronous set to 0 input
//     input wire set_to_1,    // Asynchronous set to 1 input
//     input wire [1:0] init_value, // Initial value input
//     input wire lock,        // Lock input to set initial value
//     output reg [1:0] count  // 2-bit counter output
// );

//     always @(posedge clk or posedge reset or posedge set_to_0 or posedge set_to_1 or posedge lock) begin
//         if (reset) begin
//             count <= 2'b00;  // Reset counter to 0
//         end else if (set_to_0) begin
//             count <= 2'b00;  // Set counter to 0
//         end else if (set_to_1) begin
//             count <= 2'b01;  // Set counter to 1
//         end else if (lock) begin
//             count <= init_value;  // Set counter to initial value
//         end else begin
//             count <= count + 1;  // Increment counter
//         end
//     end

// endmodule

// module tb_two_bit_counter;

//     // Inputs
//     reg clk;
//     reg reset;
//     reg set_to_0;
//     reg set_to_1;
//     reg [1:0] init_value;
//     reg lock;

//     // Outputs
//     wire [1:0] count;

//     // Instantiate the Unit Under Test (UUT)
//     two_bit_counter uut (
//         .clk(clk),
//         .reset(reset),
//         .set_to_0(set_to_0),
//         .set_to_1(set_to_1),
//         .init_value(init_value),
//         .lock(lock),
//         .count(count)
//     );

//     // Clock generation
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk; // 10ns period clock
//     end

//     // Test sequence
//     initial begin
//         // Initialize Inputs
//         reset = 0;
//         set_to_0 = 0;
//         set_to_1 = 0;
//         init_value = 2'b00;
//         lock = 0;

//         // Monitor the output
//         $monitor("Time: %0t | clk: %b | reset: %b | set_to_0: %b | set_to_1: %b | init_value: %b | lock: %b | count: %b", 
//                  $time, clk, reset, set_to_0, set_to_1, init_value, lock, count);

//         // Apply reset
//         reset = 1; #10;
//         reset = 0; #10;

//         // Set counter to 0
//         set_to_0 = 1; #10;
//         set_to_0 = 0; #10;

//         // Set counter to 1
//         set_to_1 = 1; #10;
//         set_to_1 = 0; #10;

//         // Set initial value to 2 and lock
//         init_value = 2'b10;
//         lock = 1; #10;
//         lock = 0; #10;

//         // Increment counter
//         #50;

//         // Set initial value to 3 and lock
//         init_value = 2'b11;
//         lock = 1; #10;
//         lock = 0; #10;

//         // Increment counter
//         #50;

//         $finish;
//     end

// endmodule

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

module tb_two_bit_counter;

    // Inputs
    reg clk;
    reg reset;
    reg [1:0] init_value;
    reg lock;

    // Outputs
    wire [1:0] count;

    // Instantiate the Unit Under Test (UUT)
    two_bit_counter uut (
        .clk(clk),
        .reset(reset),
        .init_value(init_value),
        .lock(lock),
        .count(count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        reset = 0;
        init_value = 2'b00;
        lock = 0;

        // Monitor the output
        $monitor("Time: %0t | clk: %b | reset: %b | init_value: %b | lock: %b | count: %b", 
                 $time, clk, reset, init_value, lock, count);

        // Apply reset
        reset = 1; #10;
        reset = 0; #10;

        // Set initial value to 2 and lock
        init_value = 2'b10;
        lock = 1; #10;
        lock = 0; #10;

        // Increment counter
        #50;

        // Set initial value to 3 and lock
        init_value = 2'b11;
        lock = 1; #10;
        lock = 0; #10;

        // Increment counter
        #50;

        $finish;
    end

endmodule