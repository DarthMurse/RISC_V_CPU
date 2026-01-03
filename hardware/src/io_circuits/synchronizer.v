`timescale 1ns/1ns

module synchronizer #(parameter WIDTH = 1) (
  input [WIDTH-1:0] async_signal,
  input clk,
  output [WIDTH-1:0] sync_signal
);

  // TODO: Your code
  reg [WIDTH-1:0] sync_stage1;
  reg [WIDTH-1:0] sync_stage2;
  always @(posedge clk) begin
    sync_stage1 <= async_signal;
    sync_stage2 <= sync_stage1;
  end
  assign sync_signal = sync_stage2;

endmodule
