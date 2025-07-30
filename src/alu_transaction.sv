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
  constraint CMD_WEIGHTAGE {if(MODE == 1) CMD dist { [0:3]:= 5, [8:9] :=5 , [4:7]:=1, 10:=1};
                            else if(MODE == 0) CMD dist { [0:1]:= 5, [3:5]:=5, [12:13]:=3, 2:=1, [6:11]:=1};
  }
  //3. for INP_VALID range
  constraint INP_VALID_RANGE { INP_VALID dist {2'b01 :=5, 2'b10 := 5, 2'b11 := 10}; }
  // 4. OPA and OPB range
  constraint OP_RANGE { OPA inside {[0:30]} && OPB inside {[0:30]}; }

  //METHODS ...
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

class alu_arithmetic extends alu_transaction;  // Test case 1 : To check the output when MODE == 1 [Arithmetic] with CMD inside 0 to 10 

  constraint cmd_range { CMD inside {[0:3], [8:9]}; } //single operand operation
  constraint mode_val { MODE == 1; }
  constraint inp_val { INP_VALID dist { 2'b11 :=8, 2'b10 :=8, 2'b01:=20}; }

  virtual function alu_transaction copy();

    alu_arithmetic copy1;
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


class alu_logical extends alu_transaction; // Test case 2 : To check the output when MODE == 0 [LOGICAL] with CMD inside 0 to 13 

  constraint cmd_range { CMD inside {[0:1], [3:5], [12:13]}; }
  constraint cmd_val   { if(CMD == 13) OPB < 8; }
  constraint mode_val { MODE == 0; }
  constraint inp_val { INP_VALID dist {2'b11 := 8, 2'b10 := 20, 2'b01 := 9}; }
  constraint weight_cin { CIN dist { 1:=2, 0:= 5}; }
  constraint op_range { (CIN inside {9,10}) -> (OPA < 20 && OPB < 15);  }

  virtual function alu_transaction copy();

    alu_logical copy2;
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
