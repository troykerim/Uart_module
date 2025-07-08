// Testbench for both the RX and TX
// In order to run UART as either Reciever or Transciever,
// you must comment out sections of the code.
// For example, for RX mode, you must comment out the TX test logic and vice versa


`timescale 1ns/10ps

module UART_TB ();

  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;

  reg r_Clock = 0;
  reg r_TX_DV = 0;
  reg [7:0] r_TX_Byte = 0;
  wire w_TX_Active, w_TX_Serial, w_RX_DV;
  wire [7:0] w_RX_Byte;
  wire w_UART_Line;

  reg [7:0] test_data[0:9];  // 10 test cases
  integer i;

  // UART Transmit and Receive Instantiation
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst (
    .i_Clock(r_Clock),
    .i_RX_Serial(w_UART_Line),
    .o_RX_DV(w_RX_DV),
    .o_RX_Byte(w_RX_Byte)
  );

  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst (
    .i_Clock(r_Clock),
    .i_TX_DV(r_TX_DV),
    .i_TX_Byte(r_TX_Byte),
    .o_TX_Active(w_TX_Active),
    .o_TX_Serial(w_TX_Serial),
    .o_TX_Done()
  );

  // UART Line Logic (idle high when not transmitting)
  assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;

  // Clock Generation
  always #(c_CLOCK_PERIOD_NS/2) r_Clock <= ~r_Clock;

      // Main Test Logic of RX
  initial begin
    // Diverse test patterns
    test_data[0] = 8'h37; 
    test_data[1] = 8'hA5;  
    test_data[2] = 8'hC3;  
    test_data[3] = 8'h7E;  
    test_data[4] = 8'h00;  
    test_data[5] = 8'hFF; 
    test_data[6] = 8'h81;  
    test_data[7] = 8'h42;  
    test_data[8] = 8'h19; 
    test_data[9] = 8'hE7;  

    @(posedge r_Clock);

    for (i = 0; i < 10; i = i + 1) begin
     

      // Start bit
      r_RX_Serial <= 1'b0;
      #(c_BIT_PERIOD);

      // Data bits (LSB first)
      r_RX_Serial <= test_data[i][0]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][1]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][2]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][3]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][4]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][5]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][6]; #(c_BIT_PERIOD);
      r_RX_Serial <= test_data[i][7]; #(c_BIT_PERIOD);

      // Stop bit
      r_RX_Serial <= 1'b1;
      #(c_BIT_PERIOD);

      // Wait until RX finishes decoding
      #(80000);  // Approx. 80 us per packet

      if (w_RX_Byte == test_data[i])
        $display("Test %0d Passed: RX = 0x%02h", i, w_RX_Byte);
      else
        $display("Test %0d FAILED: Expected 0x%02h, got 0x%02h", i, test_data[i], w_RX_Byte);
    end

    $display("All UART RX tests completed.");
    $finish();
  end


  // Test Logic of TX
  initial begin
    // Initialize test data
    test_data[0] = 8'h3F;
    test_data[1] = 8'hA0;
    test_data[2] = 8'hC1;
    test_data[3] = 8'h55;
    test_data[4] = 8'h00;
    test_data[5] = 8'hFF;
    test_data[6] = 8'h1C;
    test_data[7] = 8'hE3;
    test_data[8] = 8'h42;
    test_data[9] = 8'h7A;

    @(posedge r_Clock);  // Initial sync

    for (i = 0; i < 10; i = i + 1) begin
      r_TX_Byte <= test_data[i];
      r_TX_DV   <= 1'b1;
      @(posedge r_Clock);
      r_TX_DV   <= 1'b0;

      // Wait for RX to receive the byte
      wait (w_RX_DV == 1);
      @(posedge r_Clock);

      if (w_RX_Byte == test_data[i])
        $display("Test %0d Passed: TX = 0x%02h, RX = 0x%02h", i, test_data[i], w_RX_Byte);
      else
        $display("Test %0d FAILED: TX = 0x%02h, RX = 0x%02h", i, test_data[i], w_RX_Byte);

      #(c_BIT_PERIOD * 2);  // Optional delay between transmissions
    end

    $display("All UART TX tests completed.");
    $finish();
  end
endmodule
