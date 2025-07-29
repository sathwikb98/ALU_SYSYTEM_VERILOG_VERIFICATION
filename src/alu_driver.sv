class alu_driver;
  // To capture the data from generator ....
  alu_transaction drv_trans;
  // mailbox for generator to driver
  mailbox #(alu_transaction) mbx_gd;
  // mailbox for driver to refernece model
  mailbox #(alu_transaction) mbx_dr;
  // virtual interface to drive the inputs of DUV
  virtual alu_inf.DRV drv_vif;
  // event between driver and reference module

  covergroup drv_cg;
      MODE_CP: coverpoint drv_trans.MODE;
      INP_VALID_CP : coverpoint drv_trans.INP_VALID;
      CMD_CP : coverpoint drv_trans.CMD {
      bins valid_cmd[] = {[0:13]};
      illegal_bins invalid_cmd[] = default;
    }
    OPA_CP : coverpoint drv_trans.OPA {
      bins all_zeros_a = {0};
      bins opa = {[1:`MAX-1]};
      bins all_ones_a = {`MAX};
    }
    OPB_CP : coverpoint drv_trans.OPB {
      bins all_zeros_a = {0};
      bins opb = {[0:`MAX-1]};
      bins all_ones_a = {`MAX};
    }
    CIN_CP : coverpoint drv_trans.CIN;

      MODE_X_INP_VALID: cross MODE_CP, INP_VALID_CP;
      MODE_X_CMD: cross MODE_CP, CMD_CP;
      OPA_X_OPB : cross OPA_CP, OPB_CP;
      CMD_X_INP_VALID: cross CMD_CP, INP_VALID_CP;
  endgroup

  // TASKS & METHODS
  function new(mailbox #(alu_transaction) mbx_gd, mailbox #(alu_transaction) mbx_dr, virtual alu_inf.DRV drv_vif);
    this.mbx_gd = mbx_gd;
    this.mbx_dr = mbx_dr;
    this.drv_vif = drv_vif;
    // here can create new covergroup if required !!
    drv_cg = new();
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

  task drive_inf();
    drv_vif.drv_cb.OPA <= drv_trans.OPA;
    drv_vif.drv_cb.OPB <= drv_trans.OPB;
    drv_vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
    drv_vif.drv_cb.MODE <= drv_trans.MODE;
    drv_vif.drv_cb.CMD <= drv_trans.CMD;
    drv_vif.drv_cb.CIN <= drv_trans.CIN;
  endtask : drive_inf

  task start();
    int count = 0;
    //$display("DRIVER START TASK IS INITIATED ....");
    repeat(2) @(drv_vif.drv_cb);
    repeat(`no_of_transaction) begin : START_LOOP
      drv_trans = new();
      // Getting the transaction from generator !
      mbx_gd.get(drv_trans);
      drv_trans.MODE.rand_mode(1);
      drv_trans.CMD.rand_mode(1);
      // Driver logic stimuli.....
      if(drv_vif.drv_cb.RST == 0 || drv_vif.drv_cb.CE == 1) begin : CLOCK_EN
         //Here the alu-process stimuli is driven !
        if(SINGLE_OP_CMD(drv_trans.MODE, drv_trans.CMD)) begin : SINGLE_OPERAND_OP
            @(drv_vif.drv_cb); // wait for one cycle
            mbx_dr.put(drv_trans);
            $display("");
         end : SINGLE_OPERAND_OP
          else begin : BOTH_OPERAND_OP // Its an 2 OPERAND operation so need to check for INP_VALID to consider
              if(drv_trans.INP_VALID == 2'b01 || drv_trans.INP_VALID == 2'b10) begin : INP_VALID_alternate
              drive_inf();
//              $display("[TIME : %2t] DRIVING DATA TO INTERFACE: INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b",$time, drv_trans.INP_VALID, drv_trans.MODE, drv_trans.CMD, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
              drv_trans.MODE.rand_mode(0);
              drv_trans.CMD.rand_mode(0);
              //mbx_dr.put(drv_trans);
              @(drv_vif.drv_cb); // wait for one cycle
              for(int i = 0; i < 16; i++) begin : wait_16_cycle
       //       $display("[ TIME : %0t ] -> i[%0d]",$time,i);
                void'(drv_trans.randomize());
                drive_inf();
//                $display("[TIME : %2t] DRIVING DATA TO INTERFACE: INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b",$time, drv_trans.INP_VALID, drv_trans.MODE, drv_trans.CMD, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
                @(drv_vif.drv_cb);
                if(drv_trans.INP_VALID == 2'b11) begin : INP_VALID_11
                  //drive_inf();
                  //@(drv_vif.drv_cb); // wait for one cycle
                  if(drv_trans.MODE == 1 && drv_trans.CMD inside {[9:10]})
                    @(drv_vif.drv_cb);
                  mbx_dr.put(drv_trans);
//                  $display("");
//                  $display("[TIME : %2t] DRIVING DATA TO REFERENCE_MODEL: INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b",$time, drv_vif.drv_cb.INP_VALID, drv_vif.drv_cb.MODE, drv_vif.drv_cb.CMD, drv_vif.drv_cb.OPA, drv_vif.drv_cb.OPB, drv_vif.drv_cb.CIN);
                  $display("");
                  break;
                end : INP_VALID_11
                else if(i == 15) begin : INVALID_REACH
                  drive_inf();
                  @(drv_vif.drv_cb); // wait for 2 cycle for reference model to capture the event
                  if(drv_trans.MODE == 1 && drv_trans.CMD inside {[9:10]})
                  @(drv_vif.drv_cb);
                  mbx_dr.put(drv_trans);
                  break;
                end : INVALID_REACH
              end : wait_16_cycle
  end : INP_VALID_alternate
  else begin : INP_VALID_11_direct
              drive_inf();
              @(drv_vif.drv_cb); // wait for one cycle
              if(drv_trans.MODE == 1 && drv_trans.CMD inside {[9:10]})
                @(drv_vif.drv_cb);
              mbx_dr.put(drv_trans);
  end : INP_VALID_11_direct
 end : BOTH_OPERAND_OP
end : CLOCK_EN
else begin : RESET
    drv_vif.drv_cb.INP_VALID <= 'd0;
    drv_vif.drv_cb.MODE <= 'd0;
    drv_vif.drv_cb.CMD <= 'd0;
    drv_vif.drv_cb.OPA <= 'd0;
    drv_vif.drv_cb.OPB <= 'd0;
    drv_vif.drv_cb.CIN <= 'd0;
    @(drv_vif.drv_cb);
    mbx_dr.put(drv_trans);
    end : RESET
    drv_cg.sample();
      //$display(" ### ------------------------------------- DRV_count : %0d ------------------------------------------------- ####",++count);
    repeat(4) @(drv_vif.drv_cb);
end : START_LOOP
endtask : start
  
endclass : alu_driver
