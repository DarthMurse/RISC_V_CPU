
module uart_transmitter #(
  parameter CLOCK_FREQ = 125_000_000,
  parameter BAUD_RATE = 115_200
) (
  input clk,
  input rst,

  input [7:0] data_in,
  input data_in_valid,
  output data_in_ready,

  output serial_out
);
  localparam IDLE = 2'b00;
  localparam START = 2'b01;
  localparam DATA = 2'b10;
  localparam STOP = 2'b11;
  localparam CLOCKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;
  localparam CLOCKS_PER_BIT_WIDTH = $clog2(CLOCKS_PER_BIT);
  localparam SAMPLES_PER_BIT = CLOCKS_PER_BIT / 2;

  reg [1:0] state;
  reg [CLOCKS_PER_BIT_WIDTH-1:0] clock_counter;
  reg [2:0] bit_index;
  reg serial_out_reg;
  reg data_in_ready_reg;

  assign serial_out = serial_out_reg;
  assign data_in_ready = data_in_ready_reg;

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      clock_counter <= 0;
      bit_index <= 0;
      serial_out_reg <= 1'b1; // Idle state is high
      data_in_ready_reg <= 1'b1;
    end else begin
      case (state)
        IDLE: begin
          clock_counter <= 0;
          bit_index <= 0;
          serial_out_reg <= 1'b1; // Idle state is high
          data_in_ready_reg <= 1'b1;
          if (data_in_valid) 
            state <= START;
          else 
            state <= IDLE;
        end
        START: begin
          serial_out_reg <= 1'b0; // Start bit
          data_in_ready_reg <= 1'b0;
          bit_index <= 0;
          if (clock_counter == CLOCKS_PER_BIT) begin
            clock_counter <= 0;
            state <= DATA;
          end else begin
            clock_counter <= clock_counter + 1;
            state <= START;
          end
        end
        DATA: begin
          serial_out_reg <= data_in[bit_index];
          data_in_ready_reg <= 1'b0;
          if (clock_counter == CLOCKS_PER_BIT) begin
            clock_counter <= 0;
            if (bit_index == 7) begin
              bit_index <= 0;
              state <= STOP;
            end else begin
              bit_index <= bit_index + 1;
              state <= DATA;
            end
          end else begin
            clock_counter <= clock_counter + 1;
            state <= DATA;
          end
        end
        STOP: begin
          serial_out_reg <= 1'b1; // Stop bit
          data_in_ready_reg <= 1'b0;
          bit_index <= 0;
          if (clock_counter == CLOCKS_PER_BIT) begin
            clock_counter <= 0;
            state <= IDLE;
          end else begin
            clock_counter <= clock_counter + 1;
            state <= STOP;
          end
        end
      endcase
    end
  end

endmodule
