import test_pkg::*;

class transaction;
  rand bit rst_n;
  rand bit alu_enable_a;
  rand bit alu_enable_b;
  rand bit alu_irq_clr;
  rand bit alu_enable;
  rand bit [1:0] alu_op_a;
  rand bit [1:0] alu_op_b;
  rand bit [7:0] alu_in_a;
  rand bit [7:0] alu_in_b;
  bit [7:0] alu_out;
  bit alu_irq;

  function transaction copy();
    copy = new();
    copy.rst_n = this.rst_n;
    copy.alu_enable_a = this.alu_enable_a;
    copy.alu_enable_b = this.alu_enable_b;
    copy.alu_irq_clr = this.alu_irq_clr;
    copy.alu_enable = this.alu_enable;
    copy.alu_op_a = this.alu_op_a;
    copy.alu_op_b = this.alu_op_b;
    copy.alu_in_a = this.alu_in_a;
    copy.alu_in_b = this.alu_in_b;
    copy.alu_out = this.alu_out;
    copy.alu_irq = this.alu_irq;
  endfunction

  function void display(string tag);
    if (tag == "MON") begin
      $display(
          "At %0t [%s]: alu_enable_a = %0d, alu_enable_b = %0d, alu_irq_clr =\ %0d, alu_enable = %0d,\
   alu_op_a = %0d, alu_op_b = %0d, alu_in_a = %0d, alu_in_b = %0d, alu_out =\ %0d,\ alu_irq = %0d ",
          $time, tag, alu_enable_a, alu_enable_b, alu_irq_clr, alu_enable, alu_op_a, alu_op_b,
          alu_in_a, alu_in_b, alu_out, alu_irq);
    end else begin
      $display(
          "At %0t [%s]: alu_enable_a = %0d, alu_enable_b = %0d, alu_irq_clr =\ %0d, alu_enable = %0d,\
   alu_op_a = %0d, alu_op_b = %0d, alu_in_a = %0d, alu_in_b = %0d ",
          $time, tag, alu_enable_a, alu_enable_b, alu_irq_clr, alu_enable, alu_op_a, alu_op_b,
          alu_in_a, alu_in_b);

    end
  endfunction

  constraint reset_value {
    rst_n dist {
      1'b1 :/ 90,
      1'b0 :/ 10
    };
  }
  constraint enables {(alu_enable_a & alu_enable_b) != 1'b1;}
  constraint enable_two_modes {
    alu_enable_a dist {
      1'b1 :/ 50,
      1'b0 :/ 50
    };
    alu_enable_b dist {
      1'b1 :/ 50,
      1'b0 :/ 50
    };
  }
  constraint enable {
    alu_enable dist {
      1'b1 :/ 95,
      1'b0 :/ 5
    };
  }
  constraint clear {
    alu_irq_clr dist {
      1'b1 :/ 80,
      1'b0 :/ 20
    };
  }
  constraint illegal_values_mode_a {
    if (alu_enable && alu_enable_a) {
      if (alu_op_a == 2'b0) {
        alu_in_b != 8'b0;
      } else
      if (alu_op_a == 2'b1) {
        alu_in_a != 8'hFF;
        alu_in_b != 8'h03;
      }
    }
  }

  constraint illegal_values_mode_b {
    if (alu_enable && alu_enable_b) {
      if (alu_op_b == 2'b01) {alu_in_b != 8'h03;} else if (alu_op_b == 2'b10) {alu_in_a != 8'hF5;}
    }
  }

  constraint trigger_irq_a {
    if (alu_enable && alu_enable_a) {
      if (alu_op_a == 2'b00) {
        alu_in_a dist {
          8'hFF :/ 80,
          [8'h0 : 8'hFE] :/ 20
        };
        alu_in_b dist {
          8'hFF :/ 80,
          [8'h0 : 8'hFE] :/ 20
        };
      } else
      if (alu_op_a == 2'b10) {
        alu_in_a dist {
          8'hF8 :/ 60,
          [8'h0 : 8'hF7] :/ 20,
          [8'hF9 : 8'hFF] :/ 20
        };
        alu_in_b dist {
          8'h0 :/ 80,
          [8'h1 : 8'hFF] :/ 20
        };
      } else
      if (alu_op_a == 2'b11) {
        alu_in_a dist {
          8'h0 :/ 60,
          [8'h1 : 8'hFF] :/ 40
        };
        alu_in_b dist {
          8'h7C :/ 60,
          [8'h0 : 8'h7B] :/ 20,
          [8'h7D : 8'hFF] :/ 20
        };
      }
    }

  }

  constraint trigger_irq_b {
    if (alu_enable && alu_enable_b) {
      if (alu_op_a == 2'b00) {
        alu_in_a dist {
          8'hFF :/ 80,
          [8'h0 : 8'hFE] :/ 20
        };
        alu_in_b dist {
          8'hF1 :/ 80,
          [8'h0 : 8'hF0] :/ 10,
          [8'hF2 : 8'hFF] :/ 10
        };
      } else
      if (alu_op_a == 2'b01) {
        alu_in_a dist {
          8'hF4 :/ 80,
          [8'h0 : 8'hF3] :/ 10,
          [8'hF5 : 8'hFF] :/ 10
        };
        alu_in_b dist {
          8'hFF :/ 80,
          [8'h0 : 8'hFE] :/ 20
        };
      } else
      if (alu_op_a == 2'b10) {
        alu_in_a dist {
          8'h0 :/ 80,
          [8'h1 : 8'hFF] :/ 20
        };
        alu_in_b dist {
          8'h0A :/ 80,
          [8'h0 : 8'h09] :/ 10,
          [8'h0B : 8'hFF] :/ 10
        };
      } else
      if (alu_op_a == 2'b11) {
        alu_in_a dist {
          8'h0F :/ 80,
          [8'h0 : 8'h0E] :/ 10,
          [8'h10 : 8'hFF] :/ 10
        };
        alu_in_b dist {
          8'hF0 :/ 80,
          [8'h0 : 8'hE0] :/ 10,
          [8'hF1 : 8'hFF] :/ 10
        };
      }
    }

  }
endclass
