class alu_generator ;
  // declaring the blueprint of type transaction class ....
  alu_transaction blueprint;
  // mailbox declared for generator to driver connection
  mailbox #(alu_transaction) mbx_gd;
  // METHODS
  // Adding new constructor so that we can add mailbox connection and also create memory for blueprint !!
  function new(mailbox #(alu_transaction) mbx_gd);
    this.mbx_gd = mbx_gd;
    blueprint = new();
  endfunction : new

  task start();
    for(int i = 0 ; i < `no_of_transaction ; i++) begin
      assert(blueprint.randomize());
      mbx_gd.put(blueprint.copy());
      //$display("[TIME : %0t] GENERATOR RANDOMIZED TRANSACTION :INP_VALID : %2b || MODE : %b || CMD : %d || CE : %0b || OPA : %0d || OPB : %0d || CIN : %d",$time, blueprint.INP_VALID,blueprint.MODE,blueprint.CMD,blueprint.CE,blueprint.OPA,blueprint.OPB,blueprint.CIN);
      //$display("----------------------------------------------------------------------------------------------------------------------------------------");
    end
  endtask
endclass : alu_generator
