
module debouncer #(
  parameter WIDTH              = 1,
  parameter SAMPLE_CNT_MAX     = 25000,
  parameter PULSE_CNT_MAX      = 150,
  parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX) + 1,
  parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
  input clk,
  input [WIDTH-1:0] glitchy_signal,
  output [WIDTH-1:0] debounced_signal
);
  reg [WRAPPING_CNT_WIDTH-1:0] sample_counters[WIDTH-1:0];
  reg [SAT_CNT_WIDTH-1:0] pulse_counters[WIDTH-1:0];
  reg [WIDTH-1:0] debounced_reg;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin
      always @(posedge clk) begin
        // Sample counter logic
        if (sample_counters[i] < SAMPLE_CNT_MAX)
          sample_counters[i] <= sample_counters[i] + 1;
        else begin
          sample_counters[i] <= 0;
          if (glitchy_signal[i]) begin
            if (pulse_counters[i] < PULSE_CNT_MAX)
              pulse_counters[i] <= pulse_counters[i] + 1;
            else begin
              pulse_counters[i] <= PULSE_CNT_MAX;
              debounced_reg[i] <= 1'b1;
            end
          end else begin
            pulse_counters[i] <= 0;
            debounced_reg[i] <= 1'b0;
          end
        end
      end
    end
  endgenerate

  assign debounced_signal = debounced_reg;

endmodule
