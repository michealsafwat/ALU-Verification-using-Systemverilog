import test_pkg::*;

class environment;
  virtual ALU_IF alu_if;
  mailbox #(transaction) g_to_d;
  mailbox #(transaction) m_to_s;
  mailbox #(transaction) m_to_s_prev;
  event done;
  event next;
  generator g;
  driver d;
  monitor m;
  scoreboard s;

  function new(virtual ALU_IF alu_if);
    this.alu_if = alu_if;
    g_to_d = new();
    m_to_s = new();
    m_to_s_prev = new();
    g = new(g_to_d);
    d = new(g_to_d);
    m = new(m_to_s,m_to_s_prev);
    s = new(m_to_s,m_to_s_prev);
    d.alu_if = this.alu_if;
    m.alu_if = this.alu_if;
    g.done = done;
    g.next = next;
    s.next = next;
  endfunction

  task pre_test();
    d.reset();
  endtask

  task test();
    fork
      g.run();
      d.run();
      m.run();
      s.run();
    join_any

  endtask

  task post_test();
    wait (g.done.triggered);
    $finish;
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass
