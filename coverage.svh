import test_pkg::*;

class coverage;

  transaction trans;

  covergroup enable_and_reset;
    option.auto_bin_max = 256;
    option.per_instance = 1;
    alu_enable: coverpoint trans.alu_enable;
    rst_n: coverpoint trans.rst_n {bins activated = {0}; bins deactivated = {1};}
    irq: coverpoint trans.alu_irq {bins off = {0};}
    out: coverpoint trans.alu_out {bins off = {0};}

    cross trans.alu_irq, trans.rst_n;
    cross trans.alu_out, trans.rst_n;
  endgroup


  covergroup operations;
    //option.auto_bin_max = 256;
    option.per_instance = 1;
    op_a: coverpoint trans.alu_op_a;
    op_b: coverpoint trans.alu_op_b;
  endgroup

  covergroup enable_a_and_b;
    //option.per_instance = 1;

    cross trans.alu_enable_a, trans.alu_enable_b;

  endgroup



  covergroup illegal_values_a;
    option.auto_bin_max = 256;

    coverpoint trans.alu_enable {bins enable_0 = {0}; bins enable_1 = {1};}

    coverpoint trans.alu_enable_a {bins enable_a_0 = {0}; bins enable_a_1 = {1};}

    coverpoint trans.alu_in_a {bins illegal_a = {255};}

    coverpoint trans.alu_in_b {bins illegal_b_1 = {0}; bins illegal_b_2 = {3};}

    coverpoint trans.alu_op_a;
    cross trans.alu_op_a, trans.alu_enable_a, trans.alu_in_a, trans.alu_enable;
    cross trans.alu_op_a, trans.alu_enable_a, trans.alu_in_b, trans.alu_enable;
  endgroup

  covergroup illegal_values_b;
    option.auto_bin_max = 256;

    coverpoint trans.alu_enable {bins enable_0 = {0}; bins enable_1 = {1};}

    coverpoint trans.alu_enable_a {bins enable_a_0 = {0}; bins enable_a_1 = {1};}

    coverpoint trans.alu_in_a {bins illegal_a = {245};}

    coverpoint trans.alu_in_b {bins illegal_b = {3};}

    coverpoint trans.alu_op_b;
    cross trans.alu_op_b, trans.alu_enable_b, trans.alu_in_a, trans.alu_enable;
    cross trans.alu_op_b, trans.alu_enable_b, trans.alu_in_b, trans.alu_enable;
  endgroup

  covergroup clear_irq_trigger_a;

    option.auto_bin_max = 256;

    coverpoint trans.alu_enable {bins enable_1 = {1};}

    coverpoint trans.alu_enable_a {bins enable_a_1 = {1};}


    coverpoint trans.alu_out {
      bins trigger_out_1 = {255};
      bins trigger_out_2 = {0};
      bins trigger_out_3 = {248};
      bins trigger_out_4 = {131};
    }

    coverpoint trans.alu_irq_clr {bins high = {1};}

    coverpoint trans.alu_op_a {bins AND = {0}; bins NAND = {1}; bins OR = {2}; bins XOR = {3};}

    cross trans.alu_op_a, trans.alu_enable_a, trans.alu_out, trans.alu_enable, trans.alu_irq_clr;
  endgroup

  covergroup clear_irq_trigger_b;

    option.auto_bin_max = 256;

    coverpoint trans.alu_enable {bins enable_1 = {1};}

    coverpoint trans.alu_enable_b {bins enable_b_1 = {1};}

    coverpoint trans.alu_out {
      bins trigger_out_1 = {241};
      bins trigger_out_2 = {244};
      bins trigger_out_3 = {245};
      bins trigger_out_4 = {255};
    }

    coverpoint trans.alu_irq_clr {bins high = {1};}

    coverpoint trans.alu_op_b {bins XOR = {0}; bins AND = {1}; bins NOR = {2}; bins OR = {3};}
    cross trans.alu_op_b, trans.alu_enable_b, trans.alu_out, trans.alu_enable, trans.alu_irq_clr;
  endgroup



  function new();
    enable_and_reset = new();
    operations = new();
    enable_a_and_b = new();
    illegal_values_a = new();
    illegal_values_b = new();
    clear_irq_trigger_a = new();
    clear_irq_trigger_b = new();

  endfunction


  task collect_coverage(input transaction trans);
    this.trans = trans;
    enable_and_reset.sample();
    operations.sample();
    enable_a_and_b.sample();
    illegal_values_a.sample();
    illegal_values_b.sample();
    clear_irq_trigger_a.sample();
    clear_irq_trigger_b.sample();
  endtask

endclass
