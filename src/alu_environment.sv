class alu_environment;
  virtual alu_inf drv_vif;
  virtual alu_inf mon_vif;
  virtual alu_inf ref_vif;
  
  event ev_rm; // EVENT between ref and mon

  // mailbox for gen -> driv, driv -> ref , ref -> scb & mon -> scb
  mailbox #(alu_transaction) mbx_gd;
  mailbox #(alu_transaction) mbx_dr;
  mailbox #(alu_transaction) mbx_rs;
  mailbox #(alu_transaction) mbx_ms;

  //Declaring the components for generator, driver, monitor, reference model and scoreboard
  alu_generator gen;
  alu_driver drv;
  alu_monitor mon;
  alu_reference_model ref_sb;
  alu_scoreboard scb;

  //METHODS
  // Explicity connection DRIVER, MONITOR, REFERENCE_MODEL to VI
  function new(virtual alu_inf drv_vif, virtual alu_inf mon_vif, virtual alu_inf ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction : new
  // TASK for creating mailboxes and objects of all the classes
  task build();
    begin
      // creating mailbox
      mbx_gd = new();
      mbx_dr = new();
      mbx_rs = new();
      mbx_ms = new();
      // instantiating objects and passing arguments
      gen = new(mbx_gd);
      drv = new(mbx_gd, mbx_dr, drv_vif);
      mon = new(mon_vif, mbx_ms, ev_rm);
      ref_sb = new(mbx_dr,mbx_rs,ref_vif, ev_rm);
      scb = new(mbx_rs, mbx_ms);
    end
  endtask : build

  task start();
    fork
      gen.start();
      drv.start();
      mon.start();
      scb.start();
      ref_sb.start();
    join
    scb.compare_report();
  endtask : start

endclass
