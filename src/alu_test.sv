class alu_test;
  // PROPERTIES
  // virtaul interface for driver, monitor and reference model
  virtual alu_inf drv_vif;
  virtual alu_inf mon_vif;
  virtual alu_inf ref_vif;

  // Declaring handle for environment
  alu_environment env;

  // METHODS
  // Connecting VI from driver, monitor, reference model to test
  function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction : new

  // TASK which builds and runs environment class !!
  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    env.start;
  endtask : run

endclass : alu_test


class alu_test_arithmetic extends alu_test;
  alu_arithmetic trans_arth;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_arth = new();
      env.gen.blueprint = trans_arth;
    end
    env.start();
  endtask

endclass : alu_test_arithmetic

class alu_test_logical extends alu_test;

  alu_logical trans_log;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_log = new();
      env.gen.blueprint = trans_log;
    end
    env.start();
  endtask

endclass

class alu_regression_test extends alu_test;
  alu_transaction trans;
  alu_arithmetic trans_1;
  alu_logical trans_2;

  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;

    // test 1 - base test .....
    trans = new();
    env.gen.blueprint = trans;
    env.start();

    // test 2
    trans_1 = new();
    env.gen.blueprint = trans_1;
    env.start();

    // test 3
    trans_2 = new();
    env.gen.blueprint = trans_2;
    env.start();

  endtask

endclass
