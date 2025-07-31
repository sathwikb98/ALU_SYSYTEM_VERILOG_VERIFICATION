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


class alu_test_arithematic extends alu_test;
  alu_arithematic trans_arth;
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

endclass : alu_test_arithematic

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

class alu_test_arithematic_dual_op extends alu_test;

  alu_arithematic_dual_op trans_arth_d;
  function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
      trans_arth_d = new();
      env.gen.blueprint = trans_arth_d;
    end
    env.start();
  endtask

endclass

class alu_test_arithematic_single_op extends alu_test;
    alu_arithematic_single_op trans_arth_s;
    function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
          super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
       env = new(drv_vif,mon_vif,ref_vif);
       env.build;
      begin
        trans_arth_s = new();
        env.gen.blueprint = trans_arth_s;
      end
      env.start();
    endtask

endclass

class alu_test_logical_dual_op extends alu_test;
    alu_logical_dual_op trans_log_d;
    function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
      super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
      env = new(drv_vif,mon_vif,ref_vif);
      env.build;
      begin
        trans_log_d = new();
        env.gen.blueprint = trans_log_d;
      end
      env.start();
    endtask

endclass

class alu_test_logical_single_op extends alu_test;
    alu_logical_single_op trans_log_s;
    function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
          super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
      env = new(drv_vif,mon_vif,ref_vif);
      env.build;
      begin
        trans_log_s = new();
        env.gen.blueprint = trans_log_s;
      end
      env.start();

    endtask

endclass

class alu_regression_test extends alu_test;
  alu_transaction trans;
  alu_arithematic trans_1;
  alu_logical trans_2;
  alu_arithematic_dual_op trans_3;
  alu_arithematic_single_op trans_4;
  alu_logical_dual_op trans_5;
  alu_logical_single_op trans_6;

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

    // test 4
    trans_3 = new();
    env.gen.blueprint = trans_3;
    env.start();

    // test 5
    trans_4 = new();
    env.gen.blueprint = trans_4;
    env.start();

    // test 6
    trans_5 = new();
    env.gen.blueprint = trans_5;
    env.start();

    // test 7
    trans_6 = new();
    env.gen.blueprint = trans_6;
    env.start();

  endtask

endclass
