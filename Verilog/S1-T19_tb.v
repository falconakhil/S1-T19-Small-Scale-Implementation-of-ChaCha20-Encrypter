//testbench for main module
module main_tb;
    // Inputs
    reg clk;
    reg reset;
    reg [7:0] key;
    reg [1:0] nonce;
    reg  plain_text_input1;
    reg plain_text_input2;
    reg lock;
    reg [1:0] init_value;

    // Outputs
    wire final_output;

    // Instantiate the main module
    main uut (
        .clk(clk),
        .reset(reset),
        .key(key),
        .nonce(nonce),
        .plain_text_input1(plain_text_input1),
        .plain_text_input2(plain_text_input2),
        .init_value(init_value),
        .lock(lock),
        .final_output(final_output)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        key = 8'h00;
        nonce = 2'b00;
        plain_text_input1 = 1'b0;
        plain_text_input2 = 1'b0;
        lock = 0;
        init_value = 2'b00;

        // Dump waveform data
        $dumpfile("S1-T19.vcd");
        $dumpvars(0, main_tb);

        // Apply test vectors
        #10 reset=0;
        #10 key = 8'b11011011; nonce = 2'b11; lock = 1;init_value = 2'b01;
        #10 lock = 0;
        #10 plain_text_input1 = 1'b1;
        #10 plain_text_input1 = 1'b0;
        #10 plain_text_input1 = 1'b1;
        #10 plain_text_input1 = 1'b0;
        #10 plain_text_input1 = 1'b1;
        #10 plain_text_input1 = 1'b0;

        // #50 reset = 1;
        #10 reset = 0; key = 8'b11011011; nonce = 2'b00; plain_text_input1 = 1'b0;;

        // Finish simulation
        #100 $finish;
    end

    initial begin
        // Monitor the outputs
        $monitor("At time %t, key = %b, nonce = %b, plain_text_input1 = %b,plain_text_input0 = %b, lock = %b, counter_init_value = %b, final_output = %b",
                 $time, key, nonce, plain_text_input1,plain_text_input2, lock, init_value,final_output);
    end
endmodule

