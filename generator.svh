import test_pkg::*;

class generator;
  mailbox #(transaction) mbx;
  event next;
  event done;
  transaction trans;
  int count = 0;

  function new(mailbox#(transaction) mbx);
    trans = new();
    this.mbx = mbx;
  endfunction
  
  task run();
    repeat (count) begin
      assert (trans.randomize)
      else $error("[GEN] Randomization failed\n");

      enables :
      assert ((trans.alu_enable_a & trans.alu_enable_b) != 1)
      else $error("[GEN] Both enables for mode 'a' and mode 'b' are high!");

      illega_a_1 :
      assert (((trans.alu_enable_a && (trans.alu_op_a == 2'b0)) && (trans.alu_in_b == 8'b0)) != 1)
      else $error("[GEN] illegal value in mode 'a'!");

      illega_a_2 :
      assert (((trans.alu_enable_a && (trans.alu_op_a == 2'b01)) && (trans.alu_in_b == 8'h03) && (trans.alu_in_a == 8'hff)) != 1)
      else $error("[GEN] illegal value in mode 'a'!");

      illega_b_1 :
      assert (((trans.alu_enable_b && (trans.alu_op_b == 2'b01)) && (trans.alu_in_b == 8'h03)) != 1)
      else $error("[GEN] illegal value in mode 'b'!");

      illega_b_2 :
      assert (((trans.alu_enable_b && (trans.alu_op_b == 2'b10)) && (trans.alu_in_a == 8'hf5)) != 1)
      else $error("[GEN] illegal value in mode 'b'!");

      trans.display("GEN");
      mbx.put(trans.copy());
      @(next);
    end
    ->done;
  endtask
endclass
