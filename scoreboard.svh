import test_pkg::*;
bit [7:0] excpected_out;
bit [9:0] event_trigger_a[4] = '{10'h0FF, 10'h100, 10'h2F8, 10'h383};
bit [9:0] event_trigger_b[4] = '{10'h0F1, 10'h1F4, 10'h2F5, 10'h3FF};
transaction trans;
transaction prev_trans;
bit trigger;

class scoreboard;

  mailbox #(transaction) mbx;
  mailbox #(transaction) mbx_prev;
  event next;
  coverage c;


  function new(mailbox#(transaction) mbx, mbx_prev);
    this.mbx = mbx;
    this.mbx_prev = mbx_prev;
    c = new();
  endfunction

  task run();
    forever begin
      mbx_prev.get(prev_trans);
      mbx.get(trans);
      c.collect_coverage(trans);

      $display("[SCB]: RESET = %0d\n", trans.rst_n);



      if (trans.rst_n == 1'b1) begin
        if (trans.alu_enable == 1'b1) begin
          if ((trans.alu_enable_a | trans.alu_enable_b) == 1'b0) begin
            $display("[SCB]: The two modes are off so the outputs should remain the same\n");
            if (prev_trans.alu_out != trans.alu_out) begin

              $display("[SCB]: Output changed while the two modes are off \n");
              $display(
                  "[SCB]: Previous output is alu_out = %0d, \n Current output is alu_out = %0d\n ",
                  prev_trans.alu_out, trans.alu_out);
              $display("[SCB]: MISMATCH\n");
              $display(
                  "****************************************************************************************************");
            end else if ((prev_trans.alu_irq_clr == 1'b0) && (trans.alu_irq == prev_trans.alu_irq) ) begin


              $display(
                  "[SCB]: Previous outputs are alu_out = %0d, alu_irq = %0d\n Current outputs are alu_out = %0d, alu_irq = %0d\n  ",
                  prev_trans.alu_out, prev_trans.alu_irq, trans.alu_out, trans.alu_irq);
              $display("[SCB]: PASSED\n");

              $display(
                  "****************************************************************************************************");


            end
        else if ((prev_trans.alu_irq_clr == 1'b0) && (trans.alu_irq != prev_trans.alu_irq) ) begin


              $display(
                  "[SCB]: Previous output is alu_irq = %0d\n Current output is alu_irq = %0d\n  ",
                  prev_trans.alu_irq, trans.alu_irq);
              $display("[SCB]: MISMATCH\n");

              $display(
                  "****************************************************************************************************");


            end else if (((prev_trans.alu_irq_clr == 1'b1) && (trans.alu_irq == 1'b0))) begin

              $display(
                  "[SCB]: Previous outputs are alu_out = %0d, alu_irq = %0d\n, alu_irq_clr is high so alu_irq should be low, Current outputs are alu_out = %0d, alu_irq = %0d\n  ",
                  prev_trans.alu_out, prev_trans.alu_irq, trans.alu_out, trans.alu_irq);
              $display("[SCB]: PASSED\n");

              $display(
                  "****************************************************************************************************");

            end else if (((prev_trans.alu_irq_clr == 1'b1) && (trans.alu_irq == 1'b1))) begin

              $display(
                  "[SCB]: Previous output is alu_irq = %0d, current alu_irq should be low, Current output is alu_irq = %0d\n  ",
                  prev_trans.alu_irq, trans.alu_irq);
              $display("[SCB]: MISMATCH\n");

              $display(
                  "****************************************************************************************************");

            end
          end
          /////////////////////////////////////////////////////////////
          mode_a_or_b(trans.alu_enable_a, trans.alu_enable_b);

        end else begin
          $display("[SCB]: alu_enable is off so the outputs should remain the same\n");
          if (prev_trans.alu_out != trans.alu_out || prev_trans.alu_irq != trans.alu_irq) begin
            $display("[SCB]: Outputs changed while the alu is not enabled \n");
            $display(
                "[SCB]: Previous outputs are alu_out = %0d, alu_irq = %0d\n Current outputs are alu_out = %0d, alu_irq = %0d\n ",
                prev_trans.alu_out, prev_trans.alu_irq, trans.alu_out, trans.alu_irq);
            $display("[SCB]: MISMATCH\n");

            $display(
                "****************************************************************************************************");

          end else begin
            $display(
                "[SCB]: Previous outputs are alu_out = %0d, alu_irq = %0d\n Current outputs are alu_out = %0d, alu_irq = %0d\n ",
                prev_trans.alu_out, prev_trans.alu_irq, trans.alu_out, trans.alu_irq);
            $display("[SCB]: PASSED\n");

            $display(
                "****************************************************************************************************");

          end
        end
      end else begin
        if (trans.alu_out != 8'b0 || trans.alu_irq != 1'b0) begin
          $display("[SCB]: Reset is activated but outputs are not low\n");
          $display("[SCB]: MISMATCH\n");
          $display(
              "****************************************************************************************************");
        end else begin
          $display("[SCB]: Reset is activated and outputs are low\n");
          $display("[SCB]: PASSED\n");
          $display(
              "****************************************************************************************************");
        end
      end
      ->next;
    end

  endtask


endclass


