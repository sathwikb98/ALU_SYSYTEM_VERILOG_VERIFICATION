class alu_scoreboard;
  //declaring transaction class | one for actual result from monitor | one for expected result from ref model

  alu_transaction exp_trans;
  alu_transaction act_trans;

  // mailbox for monitor and scoreboard
  mailbox #(alu_transaction) mb_ms;
  // mailbox for ref model and scoreboard
  mailbox #(alu_transaction) mb_rs;

  int MATCH = 0;
  int MISMATCH = 0;

  function new(mailbox #(alu_transaction) mb_rs,mailbox #(alu_transaction) mb_ms);
    this.mb_ms = mb_ms;
    this.mb_rs = mb_rs;
  endfunction

  task start();
    for(int i = 0; i < `no_of_transaction; i++) begin : forloop
      exp_trans = new();
      act_trans = new();
      $display("\n####################### SOCREBOARD COMPARISON [COUNT : %0d] ####################################\n",(i+1));
      fork
        begin
          mb_ms.get(act_trans); // getting actual output from monitor
          $display("\n[%0t] | MONITOR | OPA = %0d | OPB = %0d | CIN = %0d | MODE = %0d | INP_VALID = %0d | CMD = %0d | RES = %0d | OFLOW = %0b | COUT = %0b | G = %0b | L = %0b | E = %0b | ERR = %0b |\n",$time,act_trans.OPA, act_trans.OPB, act_trans.CIN, act_trans.MODE, act_trans.INP_VALID, act_trans.CMD, act_trans.RES,act_trans.OFLOW,act_trans.COUT,act_trans.G,act_trans.L,act_trans.E,act_trans.ERR);
        end
        begin
          mb_rs.get(exp_trans); // getting expected result from the monitor
          $display("\n[%0t] | REF_MODEL | OPA = %0d | OPB = %0d | CIN = %0d | MODE = %0d | INP_VALID = %0d | CMD = %0d | RES = %0d | OFLOW = %0b | COUT = %0b | G = %0b | L = %0b | E = %0b | ERR = %0b |\n",$time,exp_trans.OPA, exp_trans.OPB, exp_trans.CIN,exp_trans.MODE,exp_trans.INP_VALID,exp_trans.CMD,exp_trans.RES,exp_trans.OFLOW,exp_trans.COUT,exp_trans.G,exp_trans.L,exp_trans.E,exp_trans.ERR);
        end
      join
    $display("\n----------------------- SOCREBOARD COMPARISON END ------------------------------------------------\n");
    if(i != (`no_of_transaction- 1))
      compare_report();
    end : forloop

  endtask

  task compare_report();
    $display("\n######################## GENERATED REPORT :- #####################################################\n");
    if(
      act_trans.RES === exp_trans.RES &&
      act_trans.OFLOW === exp_trans.OFLOW &&
      act_trans.COUT === exp_trans.COUT &&
      act_trans.G === exp_trans.G &&
      act_trans.L === exp_trans.L &&
      act_trans.E === exp_trans.E &&
      act_trans.ERR === exp_trans.ERR
    ) begin : if_match
        MATCH = MATCH + 1;
        $display(" MATCH SUCCESSFUL | MATCH COUNT = %0d ",MATCH);
    end : if_match

    else begin : mismatch
      MISMATCH = MISMATCH + 1;
      $display("MATCH FAILED | MISMATCH COUNT = %0d",MISMATCH);
    end : mismatch

    $display("TOTAL :- MATCH : %0d, MISMATCH : %0d",MATCH,MISMATCH);
    $display("\n---------------------- END OF GENERATED REPORT ---------------------------------------------------\n");

  endtask

endclass
