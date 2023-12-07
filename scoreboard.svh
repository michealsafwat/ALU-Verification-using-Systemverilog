import test_pkg::*;

class scoreboard;
  transaction trans;
  transaction prev_trans;
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbx_prev;
  event next;
  coverage c;
  bit [7:0] excpected_out;
  bit [9:0] event_trigger_a[4] = '{10'h0FF, 10'h100, 10'h2F8, 10'h383};
  bit [9:0] event_trigger_b[4] = '{10'h0F1, 10'h1F4, 10'h2F5, 10'h3FF};
  bit trigger;

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
          end else if (trans.alu_enable_a == 1'b1) begin
            case (trans.alu_op_a)
              2'b00: excpected_out = trans.alu_in_a & trans.alu_in_b;
              2'b01: excpected_out = ~(trans.alu_in_a & trans.alu_in_b);
              2'b10: excpected_out = trans.alu_in_a | trans.alu_in_b;
              2'b11: excpected_out = trans.alu_in_a ^ trans.alu_in_b;
            endcase
            $display(
                "[SCB]: Operating in mode 'a', alu_op_a = %0d, alu_in_a = %0d, alu_in_b = %0d\n ",
                trans.alu_op_a, trans.alu_in_a, trans.alu_in_b);
            if (excpected_out == trans.alu_out) begin
              foreach (event_trigger_a[i]) begin
                if (event_trigger_a[i] == {trans.alu_op_a, excpected_out}) begin
                  trigger = 1'b1;
                  break;
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
                  $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ",
                           trans.alu_irq, 1);
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
                  $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ",
                           trans.alu_irq, 0);
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
            end else begin
              $display(
                  "[SCB]: Actual output is alu_out = %0d\n Expected output is alu_out = %0d\n ",
                  trans.alu_out, excpected_out);
              $display("[SCB]: MISMATCH\n");

              $display(
                  "****************************************************************************************************");

            end

          end else if (trans.alu_enable_b == 1'b1) begin
            case (trans.alu_op_b)
              2'b00: excpected_out = ~(trans.alu_in_a ^ trans.alu_in_b);
              2'b01: excpected_out = trans.alu_in_a & trans.alu_in_b;
              2'b10: excpected_out = ~(trans.alu_in_a | trans.alu_in_b);
              2'b11: excpected_out = trans.alu_in_a | trans.alu_in_b;
            endcase
            $display(
                "[SCB]: Operating in mode 'b', alu_op_b = %0d, alu_in_a = %0d, alu_in_b = %0d\n ",
                trans.alu_op_b, trans.alu_in_a, trans.alu_in_b);
            if (excpected_out == trans.alu_out) begin
              foreach (event_trigger_b[i]) begin
                if (event_trigger_b[i] == {trans.alu_op_b, excpected_out}) begin
                  trigger = 1'b1;
                  break;
                end
              end
              if (trigger == 1'b1) begin
                $display("[SCB]: EVENT TRIGGERED  \n ");
                if (trans.alu_irq == 1'b1) begin
                  $display(
                      "[SCB]: Actual outputs are alu_out = %0d, alu_irq = %0d\n Expected outputs are alu_out = %0d, alu_irq = %0d\n ",
                      trans.alu_out, trans.alu_irq, excpected_out, 1);
                  $display("[SCB]: PASSED\n");

                  $display(
                      "****************************************************************************************************");

                end else begin
                  $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ",
                           trans.alu_irq, 1);
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
                  $display("[SCB]: Actual alu_irq = %0d\n Expected alu_irq = %0d\n ",
                           trans.alu_irq, 0);
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
            end else begin
              $display(
                  "[SCB]: Actual output is alu_out = %0d\n Expected output is alu_out = %0d\n ",
                  trans.alu_out, excpected_out);
              $display("[SCB]: MISMATCH\n");

              $display(
                  "****************************************************************************************************");

            end

          end


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
