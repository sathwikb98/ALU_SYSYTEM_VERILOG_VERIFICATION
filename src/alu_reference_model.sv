class alu_reference_model;
  // Properties
  // alu_transaction handle
  alu_transaction ref_trans;
  // mailbox for driver to reference model
  mailbox #(alu_transaction) mbx_dr;
  // mailbox for reference to scoreboard
  mailbox #(alu_transaction) mbx_rs;
  // virtual interface
  virtual alu_inf.REF_SB ref_vif;
  // event to synchronize the reference model and monitor
  event ev_rm;
  // localparam used in rotation width for logical operation
  localparam ROL_WIDTH = $clog2(`OP_WIDTH);
  reg [ROL_WIDTH-1 : 0] rotation ;
  reg [(`OP_WIDTH - (ROL_WIDTH+2)) : 0] err_flag;

  // new constructor to implement mailboxs and interface connection
  function new(mailbox #(alu_transaction) mbx_dr, mailbox #(alu_transaction) mbx_rs, virtual alu_inf.REF_SB ref_vif, event ev_rm);
    this.mbx_dr = mbx_dr;
    this.mbx_rs = mbx_rs;
    this.ref_vif = ref_vif;
    this.ev_rm = ev_rm; // added event !
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

  task alu_process();

    begin : REFERENCE_MODEL_FUNC
        if(ref_vif.ref_cb.RST) begin : reset

           ref_trans.RES = {`OP_WIDTH+1{1'bz}};
           ref_trans.OFLOW = 1'bz;
           ref_trans.COUT = 1'bz;
           ref_trans.G = 1'bz;
           ref_trans.L = 1'bz;
           ref_trans.E = 1'bz;
           ref_trans.ERR = 1'bz;
        end : reset

        else if(ref_vif.ref_cb.CE) begin : CE_BLOCK

          //assigning default values
          ref_trans.RES = {`OP_WIDTH+1{1'bz}};
          ref_trans.OFLOW = 1'bz;
          ref_trans.COUT = 1'bz;
          ref_trans.G = 1'bz;
          ref_trans.L = 1'bz;
          ref_trans.E = 1'bz;
          ref_trans.ERR = 1'bz;

         if(ref_trans.MODE == 1) begin : ARITHMETIC_OPERATION
             case(ref_trans.CMD)  // `INCR_MULT,`SHIFT_MULT -> 3 clock cycle delay !
              `ADD :  // `ADD,`SUB,`ADD_CIN,`SUB_CIN,`INC_A,`DEC_A,`INC_B,`DEC_B,`CMP -> similary output after 2 clock cycle
                  begin
                    ref_trans.RES = ref_trans.OPA + ref_trans.OPB;
                    ref_trans.COUT = ref_trans.RES[`OP_WIDTH];
                  end
              `SUB :
                  begin
                    ref_trans.RES = ref_trans.OPA - ref_trans.OPB;
                    ref_trans.OFLOW = ref_trans.RES[`OP_WIDTH];
                  end
               `ADD_CIN :
                 begin
                   ref_trans.RES = ref_trans.OPA + ref_trans.OPB + ref_trans.CIN;
                   ref_trans.COUT = ref_trans.RES[`OP_WIDTH];
                 end
               `SUB_CIN :
                 begin
                   ref_trans.RES = ref_trans.OPA - (ref_trans.OPB + ref_trans.CIN);
                   ref_trans.OFLOW = (ref_trans.OPA < (ref_trans.OPB + ref_trans.CIN));
                 end
               `INC_A :
                 begin
                   ref_trans.RES = ref_trans.OPA + 1'b1;
                   ref_trans.OFLOW = ref_trans.RES[`OP_WIDTH];
                 end
               `DEC_A :
                 begin
                   ref_trans.RES = ref_trans.OPA - 1'b1;
                   ref_trans.OFLOW = ref_trans.RES[`OP_WIDTH];
                 end
               `INC_B :
                 begin
                   ref_trans.RES = ref_trans.OPB + 1'b1;
                   ref_trans.OFLOW = ref_trans.RES[`OP_WIDTH];
                 end
               `DEC_B :
                 begin
                   ref_trans.RES = ref_trans.OPB - 1'b1;
                 end
               `CMP :
                 begin
                   if(ref_trans.OPA > ref_trans.OPB ) begin
                     ref_trans.E = 1'bz;
                     ref_trans.G = 1'b1;
                     ref_trans.L = 1'bz;
                   end
                   else if(ref_trans.OPA < ref_trans.OPB) begin
                     ref_trans.E = 1'bz;
                     ref_trans.G = 1'bz;
                     ref_trans.L = 1'b1;
                   end
                   else begin // equal
                     ref_trans.E = 1'b1;
                     ref_trans.G = 1'bz;
                     ref_trans.L = 1'bz;
                   end
                 end
               `INCR_MULT :
                 begin
                    ref_trans.RES = (ref_trans.OPA + 1'b1) * (ref_trans.OPB + 1'b1) ;
                 end
               `SHIFT_MULT :
                 begin
                    ref_trans.RES = (ref_trans.OPA << 1) * (ref_trans.OPB);
                 end
               default :
                  begin
                    ref_trans.RES = 0;
                    ref_trans.ERR = 1'b1;
                  end
             endcase
          end : ARITHMETIC_OPERATION

          else begin : LOGICAL_OPERATION
            case(ref_trans.CMD) // `AND,`NAND,`OR,`NOR,`XOR,`XNOR,`NOT_A,`NOT_B,`SHR1_A,`SHL1_A,`SHR1_B,`SHL1_B,`ROL_A_B,`ROR_A_B -> 2 clk cycle delay
                `AND :
                  begin
                      ref_trans.RES = ref_trans.OPA & ref_trans.OPB;
                  end
                `NAND :
                  begin
                    ref_trans.RES = ~(ref_trans.OPA & ref_trans.OPB);
                  end
                `OR :
                  begin
                    ref_trans.RES = ref_trans.OPA | ref_trans.OPB;
                  end
                `NOR :
                  begin
                    ref_trans.RES = ~(ref_trans.OPA | ref_trans.OPB);
                  end
                `XOR :
                  begin
                    ref_trans.RES = ref_trans.OPA ^ ref_trans.OPB;
                  end
                `XNOR :
                  begin
                    ref_trans.RES = ~(ref_trans.OPA ^ ref_trans.OPB);
                  end
                `NOT_A :
                  begin
                    ref_trans.RES = ~(ref_trans.OPA);
                  end
                `NOT_B :
                  begin
                    ref_trans.RES = ~(ref_trans.OPB);
                  end
                `SHR1_A :
                  begin
                    ref_trans.RES = ref_trans.OPA >> 1;
                  end
                `SHL1_A :
                  begin
                    ref_trans.RES = ref_trans.OPA << 1;
                  end
                `SHR1_B :
                  begin
                    ref_trans.RES = ref_trans.OPB >> 1;
                  end
                `SHL1_B :
                  begin
                    ref_trans.RES = ref_trans.OPB << 1;
                  end
                `ROL_A_B :
                  begin
                    rotation = ref_trans.OPB[ROL_WIDTH-1:0];
                    err_flag = ref_trans.OPB[`OP_WIDTH-1 : ROL_WIDTH+1];
                    ref_trans.ERR = (err_flag)? 1'b1 : 1'b0;
                    ref_trans.RES = { (ref_trans.OPA << rotation) | (ref_trans.OPA >> `OP_WIDTH-rotation) };
                  end
                `ROR_A_B :
                  begin
                    rotation = ref_trans.OPB[ROL_WIDTH-1:0];
                    err_flag = ref_trans.OPB[`OP_WIDTH-1 : ROL_WIDTH+1];
                    ref_trans.ERR = (err_flag)? 1'b1 : 1'b0;
                    ref_trans.RES = { (ref_trans.OPA >> rotation) | (ref_trans.OPA << `OP_WIDTH-rotation) };

                  end
                default :
                  begin
                    ref_trans.RES = 0;
                    ref_trans.ERR = 1'b1;
                  end
              endcase

          end : LOGICAL_OPERATION
       end : CE_BLOCK
    end : REFERENCE_MODEL_FUNC

  endtask :alu_process

  task err();
     ref_trans.ERR = 1'b1;
     ref_trans.RES = {`OP_WIDTH+1{1'dz}};
     ref_trans.OFLOW = 1'dz;
     ref_trans.COUT = 1'dz;
     ref_trans.G = 1'dz;
     ref_trans.L = 1'dz;
     ref_trans.E = 1'dz;
  endtask : err

  task start();
    int count = 0;
    repeat(3) @(ref_vif.ref_cb);
    repeat(`no_of_transaction) begin : main_repeat_loop
      ref_trans = new();
      // getting the stimuli from the `alu_driver`
      mbx_dr.get(ref_trans);
      if(!SINGLE_OP_CMD(ref_trans.MODE, ref_trans.CMD)) begin : Dual_op_16_clk_wait
        if(ref_trans.INP_VALID == 2'b01 || ref_trans.INP_VALID == 2'b10) begin : if_1
          int count = 0; // counter !
          for(count =0; count < 16 ; count++) begin : for_1
            //$display("time : %0t || count : %0d || INP_VALID : %2b",$time,count,ref_trans.INP_VALID);
            if(ref_trans.INP_VALID == 2'b11) begin : for_if_1 // This is when INP_VALID is 11 from driver !!
                ref_trans.ERR = 1'b0;
                alu_process();
                @(ref_vif.ref_cb);
                if(ref_trans.MODE == 1 && ref_trans.CMD inside {[9:10]}) @(ref_vif.ref_cb); // wait for 1 cycle
                mbx_rs.put(ref_trans);
                -> ev_rm;
            //  $display("\n[TIME : %2t] Reference TO scoreboard : INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b || RES = %0d || COUT = %0d || OFLOW = %d || ERR = %0d\n",$time,ref_trans.INP_VALID, ref_trans.MODE, ref_trans.CMD, ref_trans.OPA, ref_trans.OPB, ref_trans.CIN, ref_trans.RES, ref_trans.COUT, ref_trans.OFLOW, ref_trans.ERR);
                break;
             end : for_if_1
             else if(ref_trans.INP_VALID != 2'b11) begin : for_else_if_1
                //$display("Try to get at count == 15");
                err();
                @(ref_vif.ref_cb);
                if(ref_trans.MODE == 1 && ref_trans.CMD inside {[9:10]}) @(ref_vif.ref_cb); // wait for 1 cycle
                mbx_rs.put(ref_trans);
                -> ev_rm;
               //$display("\n[TIME : %2t] Reference TO scoreboard : INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b || RES = %0d || COUT = %0d || OFLOW = %d || ERR = %0d\n",$time,ref_trans.INP_VALID, ref_trans.MODE, ref_trans.CMD, ref_trans.OPA, ref_trans.OPB, ref_trans.CIN, ref_trans.RES, ref_trans.COUT, ref_trans.OFLOW, ref_trans.ERR);
                 break;
             end : for_else_if_1
             @(ev_dr);
             mbx_dr.get(ref_trans);
          end : for_1
        end : if_1
        else if(ref_trans.INP_VALID == 2'b11) begin : else_if_1
          //$display("-----------------------------------------");
          alu_process();
          @(ref_vif.ref_cb);
          if(ref_trans.MODE == 1 && ref_trans.CMD inside {[9:10]}) @(ref_vif.ref_cb); // wait for 1 cyc
          ->ev_rm;
          mbx_rs.put(ref_trans);
//          $display("");
//          $display("[TIME : %2t] Reference TO scoreboard : INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b || RES = %0d || COUT = %0d || OFLOW = %d || ERR = %0d",$time,ref_trans.INP_VALID, ref_trans.MODE, ref_trans.CMD, ref_trans.OPA, ref_trans.OPB, ref_trans.CIN, ref_trans.RES, ref_trans.COUT, ref_trans.OFLOW, ref_trans.ERR);
//          $display("");
        end : else_if_1
        else begin :else_1
            err();
            @(ref_vif.ref_cb);
            if(ref_trans.MODE == 1 && ref_trans.CMD inside {[9:10]}) @(ref_vif.ref_cb); // wait for 1 cycle
            ->ev_rm;
            mbx_rs.put(ref_trans);
//            $display("");
//            $display("[TIME : %2t] Reference TO scoreboard : INP_VALID = %2b || MODE = %b || CMD = %2d || OPA = %0d || OPB = %0d || CIN = %0b || RES = %0d || COUT = %0d || OFLOW = %d || ERR = %0d",$time,ref_trans.INP_VALID, ref_trans.MODE, ref_trans.CMD, ref_trans.OPA, ref_trans.OPB, ref_trans.CIN, ref_trans.RES, ref_trans.COUT, ref_trans.OFLOW, ref_trans.ERR);
//            $display("");
        end : else_1

      end : Dual_op_16_clk_wait

      else if(SINGLE_OP_CMD(ref_trans.MODE, ref_trans.CMD)) begin : Single_operand_process
        if(ref_trans.INP_VALID == 2'b11 ||
           ref_trans.MODE == 1 && ref_trans.INP_VALID == 2'b01 && ref_trans.CMD inside {[4:5]} ||
           ref_trans.MODE == 1 && ref_trans.INP_VALID == 2'b10 && ref_trans.CMD inside {[6:7]} ||
           ref_trans.MODE == 0 && ref_trans.INP_VALID == 2'b01 && ref_trans.CMD inside {6,[8:9]} ||
           ref_trans.MODE == 0 && ref_trans.INP_VALID == 2'b10 && ref_trans.CMD inside {7,[10:11]}
        )
        begin : INP_11
          repeat(1) @(ref_vif.ref_cb);
          alu_process();
          -> ev_rm;
          mbx_rs.put(ref_trans);
        end : INP_11
        else begin : error
          err();
          repeat(1) @(ref_vif.ref_cb);
          -> ev_rm;
          mbx_rs.put(ref_trans);
        end : error

      end : Single_operand_process

      count++;
      //$display("ref_count : %0d",count);
      repeat(1) @(ref_vif.ref_cb);
//      $display("end");
    end : main_repeat_loop
  endtask : start

endclass : alu_reference_model
