class alu_monitor;
  // alu_transaction packet to send the data to scoreboard
  alu_transaction mon_trans;
  // mailbox from `monitor` to `scoreboard`
  mailbox #(alu_transaction) mbx_ms;
  // virtual interface to capture output !
  virtual alu_inf.MON mon_vif;

  // Event for syn between ref model and monitor
  event ev_rm;

  covergroup mon_cg;
      RES_CP : coverpoint mon_trans.RES { bins b1 = { [0:9'b111111111]}; }
      ERR_CP : coverpoint mon_trans.ERR;
      E_CP : coverpoint mon_trans.E { bins one_e = {1}; }
      G_CP : coverpoint mon_trans.G { bins one_g = {1}; }
      L_CP : coverpoint mon_trans.L { bins one_l = {1}; }
      OV_CP: coverpoint mon_trans.OFLOW;
      COUT_CP: coverpoint mon_trans.COUT;
  endgroup

  function new(virtual alu_inf.MON mon_vif, mailbox #(alu_transaction) mbx_ms, event ev_rm);
    this.mon_vif = mon_vif;
    this.mbx_ms = mbx_ms;
    this.ev_rm = ev_rm; // event between reference model and monitor
    mon_cg = new(); // coverage for results
  endfunction : new

  function int SINGLE_OP_CMD(input logic MODE , input logic[`CMD_WIDTH-1:0] CMD);
        if(MODE == 1) begin
            if(CMD inside {[0:3], [8:10]}) return 0;
            else return 1;
        end
        else begin
            if(CMD inside {[0:5], [12:13]}) return 0;
            else return 1;
        end
  endfunction : SINGLE_OP_CMD

  task drive_t();
    mon_trans.RES = mon_vif.mon_cb.RES;
    mon_trans.COUT = mon_vif.mon_cb.COUT;
    mon_trans.OFLOW = mon_vif.mon_cb.OFLOW;
    mon_trans.E = mon_vif.mon_cb.E;
    mon_trans.G = mon_vif.mon_cb.G;
    mon_trans.L = mon_vif.mon_cb.L;
    mon_trans.ERR = mon_vif.mon_cb.ERR;
  endtask : drive_t

  task start();
    repeat(2) @(mon_vif.mon_cb);
    repeat(`no_of_transaction) begin :loop
      mon_trans = new(); // generate transaction element to add the dut signal and send to scoreboard
      @(ev_rm);
      @(mon_vif.mon_cb); // Wait for a cycle then take the output from interface !
      drive_t();
      mbx_ms.put(mon_trans); // sending transaction data to scoreboard...
//      $display("");
//      $display("[Time : %0t] Monitor to Scoreboard : RES = %0d || COUT = %b || OFLOW = %b || EGL = %3b || ERR = %b",$time,mon_trans.RES,mon_trans.COUT, mon_trans.OFLOW, {mon_trans.E,mon_trans.G,mon_trans.L} , mon_trans.ERR );
//      $display("");
      mon_cg.sample();
      repeat(2) @(mon_vif.mon_cb);
    end :loop
  endtask : start
endclass : alu_monitor
