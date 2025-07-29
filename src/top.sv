`include "defines.svh"
`include "alu_inf.sv"
`include "ALU_DESIGN.sv"

parameter DW = 8, CW = 4;

module top;
  parameter delay = 10; // delay for clock generation
  // clock and reset for ALU
  bit CLK, RST, CE;
  // import all the packages defined for ALU
  import alu_package::* ;

  // instantiate ALU_INTERFACE
  alu_inf inf(.CLK(CLK), .RST(RST), .CE(CE));

  // Instantiate the `DUV` and connect it to interface
  ALU_DESIGN #(DW,CW) DUV (.CLK(inf.CLK), .RST(inf.RST), .INP_VALID(inf.INP_VALID), .MODE(inf.MODE), .CMD(inf.CMD), .CE(inf.CE), .OPA(inf.OPA), .OPB(inf.OPB), .CIN(inf.CIN), .ERR(inf.ERR), .RES(inf.RES), .OFLOW(inf.OFLOW), .COUT(inf.COUT), .G(inf.G), .L(inf.L), .E(inf.E) );

  // Tests for
  alu_test test = new(inf.DRV, inf.MON, inf.REF);
  alu_test_single_a test1 = new(inf.DRV, inf.MON, inf.REF);
  alu_test_two_a test2 = new(inf.DRV, inf.MON, inf.REF);
  alu_test_two_1 test3 = new(inf.DRV, inf.MON, inf.REF);
  alu_test_single_1 test4 = new(inf.DRV, inf.MON, inf.REF);
  alu_regression_test tr = new(inf.DRV, inf.MON, inf.REF);

  always#(delay) CLK = ~CLK;

  initial begin
    RST = 1;
    CE =  0;
    #(2*delay);
    CE = 1;
    RST = 0;
    #(delay);
  end

  initial begin
    //test.run();
    tr.run();
    #50; $finish;
  end
endmodule : top
