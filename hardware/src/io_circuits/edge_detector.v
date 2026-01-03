`timescale 1ns/1ns

module edge_detector #(
  parameter WIDTH = 1
)(
  input clk,
  input [WIDTH-1:0] signal_in,
  output [WIDTH-1:0] edge_detect_pulse
);
  reg [WIDTH-1:0] prev_signal, current_signal;

  always @(posedge clk) begin
    current_signal <= signal_in;
    prev_signal <= current_signal;
  end
  
  assign edge_detect_pulse = (~prev_signal) & current_signal;

endmodule
