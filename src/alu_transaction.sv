class alu_transaction;
  // inputs are declared as rand variables
  rand logic [1:0] INP_VALID;
  rand logic MODE;
  rand logic [`CMD_WIDTH-1:0] CMD;
  rand logic CE;
  rand logic [`OP_WIDTH-1:0] OPA;
  rand logic [`OP_WIDTH-1:0] OPB;
  rand logic CIN;
  // outputs for alu_design
  logic ERR;
  logic [`OP_WIDTH : 0] RES;
  logic OFLOW ;
  logic COUT;
  logic G, L, E ;

  // constraints
  // 1. For `command range` [CMD] according to `MODE`
  constraint CMD_RANGE { if(MODE == 1) CMD inside { [0:10] };
                         else CMD inside { [0:13] };
  }
  // 2. For `CMD weightage
  constraint CMD_WEIGHTAGE {CMD dist {[0:8]:= 5, [6:13]:=2}; }
  // ... copying object ....
  virtual function alu_transaction copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CE = this.CE;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CIN = this.CIN;
    return copy;
  endfunction : copy

endclass : alu_transaction

class alu_single_op_a extends alu_transaction;

  constraint cmd_range {CMD inside {4,5,6,7}; }
  constraint mode_val {MODE == 1;  }
  constraint inp_val { INP_VALID == 3; }

  virtual function alu_transaction copy();
    alu_single_op_a copy1;
    copy1 = new();
    copy1.INP_VALID = this.INP_VALID;
    copy1.MODE = this.MODE;
    copy1.CMD = this.CMD;
    copy1.OPA = this.OPA;
    copy1.OPB = this.OPB;
    copy1.CIN = this.CIN;

    return copy1;
  endfunction : copy
endclass


class alu_two_op_a extends alu_transaction;

  constraint cmd_range {CMD inside {[0:3], [8:10]};
                        CMD dist {[0:3]:= 2, 8:= 8, [7:10]:=2};
                        }
  constraint mode_val {MODE == 1; }
  constraint inp_val { INP_VALID == 3; }
  constraint weight_cin { CIN dist { 1:=2, 0:= 5}; }
  constraint op_range { (CIN inside {9,10}) -> (OPA < 20 && OPB < 5);  }

  virtual function alu_transaction copy();
    alu_two_op_a copy2;
    copy2 = new();
    copy2.INP_VALID = this.INP_VALID;
    copy2.MODE = this.MODE;
    copy2.CMD = this.CMD;
    copy2.OPA = this.OPA;
    copy2.OPB = this.OPB;
    copy2.CIN = this.CIN;

    return copy2;
  endfunction : copy
endclass

class alu_two_op_1 extends alu_transaction;

  constraint cmd_range {CMD inside {[0:5], 12, 13};
                        CMD dist {[0:5]:= 2, 12:=4, 13:=4 };
                        }
  constraint mode_val {MODE == 0; }
  constraint inp_val { INP_VALID == 3; }

  virtual function alu_transaction copy();
    alu_two_op_1 copy3;
    copy3 = new();
    copy3.INP_VALID = this.INP_VALID;
    copy3.MODE = this.MODE;
    copy3.CMD = this.CMD;
    copy3.OPA = this.OPA;
    copy3.OPB = this.OPB;
    copy3.CIN = this.CIN;

    return copy3;
  endfunction : copy
endclass

class alu_single_op_1 extends alu_transaction;

  constraint cmd_range {CMD inside {6,7,8,9,10,11}; }
  constraint mode_val {MODE == 0; }
  constraint inp_val { INP_VALID == 3; }

  virtual function alu_transaction copy();
    alu_single_op_1 copy4;
    copy4 = new();
    copy4.INP_VALID = this.INP_VALID;
    copy4.MODE = this.MODE;
    copy4.CMD = this.CMD;
    copy4.OPA = this.OPA;
    copy4.OPB = this.OPB;
    copy4.CIN = this.CIN;

    return copy4;
  endfunction : copy
endclass

class alu_error extends alu_transaction;

  constraint eq { (MODE == 1 && CMD == 8) -> (OPA == OPB); }
  constraint inp_val { INP_VALID inside {0,1,2}; }
  constraint weight_cin { CIN dist { 1:=2, 0:= 5}; }
  constraint op_range { (OPA == 0 || OPA ==`MAX) && (OPB == 0 || OPB == `MAX); }

  virtual function alu_transaction copy();
    alu_two_op_a copy5;
    copy5 = new();
    copy5.INP_VALID = this.INP_VALID;
    copy5.MODE = this.MODE;
    copy5.CMD = this.CMD;
    copy5.OPA = this.OPA;
    copy5.OPB = this.OPB;
    copy5.CIN = this.CIN;

    return copy5;
  endfunction : copy
endclass
