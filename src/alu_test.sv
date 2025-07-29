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


class alu_test_single_a extends alu_test;
  alu_single_op_a trans_add;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_add = new();
      env.gen.blueprint = trans_add;
    end
    env.start();
  endtask

endclass : alu_test_single_a

class alu_test_two_a extends alu_test;

  alu_two_op_a trans_2_a;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_2_a = new();
      env.gen.blueprint = trans_2_a;
    end
    env.start();
  endtask

endclass

class alu_test_two_1 extends alu_test;

  alu_two_op_1 trans_2_1;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_2_1 = new();
      env.gen.blueprint = trans_2_1;
    end
    env.start();
  endtask

endclass

class alu_test_single_1 extends alu_test;
  alu_single_op_1 trans_1;
  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;
    begin
      trans_1 = new();
      env.gen.blueprint = trans_1;
    end
    env.start();
  endtask

endclass

class alu_regression_test extends alu_test;
  alu_transaction trans;
  alu_single_op_1 trans_1;
  alu_single_op_a trans_a;
  alu_two_op_1 trans_2_1;
  alu_two_op_a trans_2_a;
  alu_error trans_e;

  function new( virtual alu_inf drv_vif,
                virtual alu_inf mon_vif,
                virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build;

    ///test
    trans = new();
    env.gen.blueprint = trans;
    env.start();

    trans_a = new();
    env.gen.blueprint = trans_a;
    env.start();

    ////test 4
    trans_1 = new();
    env.gen.blueprint = trans_1;
    env.start();

    trans_2_a = new();
    env.gen.blueprint = trans_2_a;
    env.start();

    trans_2_1 = new();
    env.gen.blueprint = trans_2_1;
    env.start();

    trans_e = new();
    env.gen.blueprint = trans_e;
    env.start();
  endtask

endclass
