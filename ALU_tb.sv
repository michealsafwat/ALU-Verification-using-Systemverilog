import test_pkg::*;

`timescale 1ns / 1ps

interface ALU_IF;
  logic alu_clk;
  logic rst_n;
  logic alu_enable_a;
  logic alu_enable_b;
  logic alu_irq_clr;
  logic alu_enable;
  logic [1:0] alu_op_a;
  logic [1:0] alu_op_b;
  logic [7:0] alu_in_a;
  logic [7:0] alu_in_b;
  logic [7:0] alu_out;
  logic alu_irq;
endinterface


module ALU_tb ();

  ALU_IF alu_if ();
  ALU DUT (
      .alu_clk(alu_if.alu_clk),
      .rst_n(alu_if.rst_n),
      .alu_enable_a(alu_if.alu_enable_a),
      .alu_enable_b(alu_if.alu_enable_b),
      .alu_irq_clr(alu_if.alu_irq_clr),
      .alu_enable(alu_if.alu_enable),
      .alu_op_a(alu_if.alu_op_a),
      .alu_op_b(alu_if.alu_op_b),
      .alu_in_a(alu_if.alu_in_a),
      .alu_in_b(alu_if.alu_in_b),
      .alu_out(alu_if.alu_out),
      .alu_irq(alu_if.alu_irq)

  );

  initial begin
    alu_if.alu_clk <= 0;
  end

  always #16.665 alu_if.alu_clk <= ~alu_if.alu_clk;

covergroup enable;
option.per_instance = 1;
coverpoint DUT.alu_enable;

endgroup




  initial begin
    test t = new(alu_if);
    t.run();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
