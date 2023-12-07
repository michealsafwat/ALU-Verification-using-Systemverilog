import test_pkg::*;

class test;
virtual ALU_IF alu_if;
environment env; 


function new(virtual ALU_IF alu_if);
this.alu_if = alu_if;
env = new(this.alu_if);

endfunction

task run();
    env.g.count = 100000;
    env.run();
endtask

endclass
