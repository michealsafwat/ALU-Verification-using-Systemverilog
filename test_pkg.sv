package test_pkg;
  `include "transaction.svh"
  `include "generator.svh"
  `include "driver.svh"
  `include "monitor.svh"
  `include "coverage.svh"
  `include "scoreboard.svh"
  `include "environment.svh"
  `include "test.svh"

  function void mode_a_or_b(bit alu_enable_a, alu_enable_b);
    if ((alu_enable_a == 1'b1) && (alu_enable_b == 1'b0)) begin
      case (trans.alu_op_a)
        2'b00: excpected_out = trans.alu_in_a & trans.alu_in_b;
        2'b01: excpected_out = ~(trans.alu_in_a & trans.alu_in_b);
        2'b10: excpected_out = trans.alu_in_a | trans.alu_in_b;
        2'b11: excpected_out = trans.alu_in_a ^ trans.alu_in_b;
      endcase
      $display("[SCB]: Operating in mode 'a', alu_op_a = %0d, alu_in_a = %0d, alu_in_b = %0d\n ",
               trans.alu_op_a, trans.alu_in_a, trans.alu_in_b);
      if (excpected_out == trans.alu_out) begin
        foreach (event_trigger_a[i]) begin
          if (event_trigger_a[i] == {trans.alu_op_a, excpected_out}) begin
            trigger = 1'b1;
            break;
          end
        end
      end else begin
        $display("[SCB]: Actual output is alu_out = %0d\n Expected output is alu_out = %0d\n ",
                 trans.alu_out, excpected_out);
        $display("[SCB]: MISMATCH\n");

        $display(
            "****************************************************************************************************");

      end
    end else if ((alu_enable_a == 1'b0) && (alu_enable_b == 1'b1)) begin
      case (trans.alu_op_b)
        2'b00: excpected_out = ~(trans.alu_in_a ^ trans.alu_in_b);
        2'b01: excpected_out = trans.alu_in_a & trans.alu_in_b;
        2'b10: excpected_out = ~(trans.alu_in_a | trans.alu_in_b);
        2'b11: excpected_out = trans.alu_in_a | trans.alu_in_b;
      endcase
      $display("[SCB]: Operating in mode 'b', alu_op_b = %0d, alu_in_a = %0d, alu_in_b = %0d\n ",
               trans.alu_op_b, trans.alu_in_a, trans.alu_in_b);
      if (excpected_out == trans.alu_out) begin
        foreach (event_trigger_b[i]) begin
          if (event_trigger_b[i] == {trans.alu_op_b, excpected_out}) begin
            trigger = 1'b1;
            break;
          end
        end
      end else begin
        $display("[SCB]: Actual output is alu_out = %0d\n Expected output is alu_out = %0d\n ",
                 trans.alu_out, excpected_out);
        $display("[SCB]: MISMATCH\n");

        $display(
            "****************************************************************************************************");

      end
    end

    if (trigger == 1'b1) begin
      $display("[SCB]: EVENT TRIGGERED \n ");
      if (trans.alu_irq == 1'b1) begin
        $display(
            "[SCB]: Actual outputs are alu_out = %0d, alu_irq = %0d\n Expected outputs are alu_out = %0d, alu_irq = %0d\n ",
            trans.alu_out, trans.alu_irq, excpected_out, 1);
        $display("[SCB]: PASSED\n");

        $display(
            "****************************************************************************************************");

      end else begin
        $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ", trans.alu_irq, 1);
        $display("[SCB]: MISMATCH\n");

        $display(
            "****************************************************************************************************");

      end
    end else begin
      if ( (prev_trans.alu_irq == 1'h1) && (prev_trans.alu_irq_clr == 1'b0) && (trans.alu_irq == 1'b1 )) begin
        $display(
            "[SCB]: Actual outputs are alu_out = %0d, alu_irq = %0d\n Expected outputs are alu_out = %0d, alu_irq = %0d\n ",
            trans.alu_out, trans.alu_irq, excpected_out, 1);
        $display("[SCB]: alu_irq was not cleared so it should remain high\n");
        $display("[SCB]: PASSED\n");

        $display(
            "****************************************************************************************************");

      end else if ((prev_trans.alu_irq_clr == 1'b1) && (trans.alu_irq == 1'b1)) begin
        $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ", trans.alu_irq, 0);
        $display("[SCB]: alu_irq should be low\n");
        $display("[SCB]: MISMATCH\n");

        $display(
            "****************************************************************************************************");

      end else if ((prev_trans.alu_irq_clr == 1'b1) && (trans.alu_irq == 1'b0)) begin
        $display(
            "[SCB]: Actual outputs are alu_out = %0d, alu_irq = %0d\n Expected outputs are alu_out = %0d, alu_irq = %0d\n ",
            trans.alu_out, trans.alu_irq, excpected_out, 0);
        $display("[SCB]: PASSED\n");

        $display(
            "****************************************************************************************************");
      end else begin
        $display(
            "[SCB]: Actual outputs are alu_out = %0d, alu_irq = %0d\n Expected outputs are alu_out = %0d, alu_irq = %0d\n ",
            trans.alu_out, trans.alu_irq, excpected_out, 0);
        $display("[SCB]: PASSED\n");

        $display(
            "****************************************************************************************************");
      end
    end
    trigger = 1'b0;





  endfunction
endpackage : test_pkg
