import test_pkg::*;

class driver;
  mailbox #(transaction) mbx;
  transaction trans;
  virtual ALU_IF alu_if;

  function new(mailbox#(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task reset();
    alu_if.rst_n <= 1'b0;
    alu_if.alu_enable_a <= 1'b0;
    alu_if.alu_enable_b <= 1'b0;
    alu_if.alu_irq_clr <= 1'b0;
    alu_if.alu_enable <= 1'b0;
    alu_if.alu_op_a <= 2'b0;
    alu_if.alu_op_b <= 2'b0;
    alu_if.alu_in_a <= 8'b0;
    alu_if.alu_in_b <= 8'b0;
    @(posedge alu_if.alu_clk);
    alu_if.rst_n <= 1'b1;
    @(posedge alu_if.alu_clk);
    $display("[DRV]: reset done");
  endtask

  task run();
    forever begin
      mbx.get(trans);
      trans.display("DRV");
      alu_if.rst_n <= trans.rst_n;
      alu_if.alu_enable_a <= trans.alu_enable_a;
      alu_if.alu_enable_b <= trans.alu_enable_b;
      alu_if.alu_irq_clr <= trans.alu_irq_clr;
      alu_if.alu_enable <= trans.alu_enable;
      alu_if.alu_op_a <= trans.alu_op_a;
      alu_if.alu_op_b <= trans.alu_op_b;
      alu_if.alu_in_a <= trans.alu_in_a;
      alu_if.alu_in_b <= trans.alu_in_b;
      //@(posedge alu_if.alu_clk);
    end
  endtask
endclass