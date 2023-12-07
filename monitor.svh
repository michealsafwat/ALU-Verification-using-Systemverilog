import test_pkg::*;

class monitor;
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbx_prev;
  virtual ALU_IF alu_if;
  transaction trans;
  transaction previous;

  function new(mailbox#(transaction) mbx, mbx_prev);
    this.mbx = mbx;
    this.mbx_prev = mbx_prev;
    trans = new();
    previous = new();
  endfunction

  task run();
    forever begin
      previous = trans.copy();
      @(posedge alu_if.alu_clk);
      trans.alu_enable_a = alu_if.alu_enable_a;
      trans.alu_enable_b = alu_if.alu_enable_b;
      trans.alu_irq_clr = alu_if.alu_irq_clr;
      trans.alu_enable = alu_if.alu_enable;
      trans.alu_op_a = alu_if.alu_op_a;
      trans.alu_op_b = alu_if.alu_op_b;
      trans.alu_in_a = alu_if.alu_in_a;
      trans.alu_in_b = alu_if.alu_in_b;
      trans.rst_n = alu_if.rst_n;

      //previous.display("MON");
    
      mbx_prev.put(previous.copy());

      @(posedge alu_if.alu_clk);
      trans.alu_out = alu_if.alu_out;
      trans.alu_irq = alu_if.alu_irq;
      
      mbx.put(trans.copy());
     
      trans.display("MON");

    end
  endtask
endclass