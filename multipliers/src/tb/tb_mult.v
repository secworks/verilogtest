//======================================================================
//
// tb_mult.v
// ---------
// Testbench for the multiplier.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2016, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module tb_mult;

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG     = 1;

  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;

  parameter API_WIDTH  = 16;
  localparam OPA_WIDTH = 64;
  localparam OPB_WIDTH = 64;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg                        tb_clk;
  reg                        tb_reset_n;
  reg                        tb_cs;
  reg                        tb_we;
  reg  [7 : 0]               tb_address;
  reg  [(API_WIDTH - 1) : 0] tb_write_data;
  wire [(API_WIDTH - 1) : 0] tb_read_data;

  reg [(API_WIDTH - 1) : 0]  read_data;

  reg [31 : 0]               cycle_ctr;
  reg [31 : 0]               error_ctr;
  reg [31 : 0]               tc_ctr;


  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  mult #(.API_WIDTH(API_WIDTH), .OPA_WIDTH(OPA_WIDTH), .OPB_WIDTH(OPB_WIDTH))
        dut(
           .clk(tb_clk),
           .reset_n(tb_reset_n),
           .cs(tb_cs),
           .we(tb_we),
           .addr(tb_address),
           .write_data(tb_write_data),
           .read_data(tb_read_data)
          );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;

      #(CLK_PERIOD);

      if (DEBUG)
        begin
          dump_dut_state();
        end
    end


  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state;
    begin
      $display("cycle: 0x%016x", cycle_ctr);
      $display("addr: 0x%02x, data = 0x%08x, cs = 0x%01x, we = 0x%01x", dut.addr, dut.write_data, dut.cs, dut.we);
      $display("operand a: 0x%064x, opa_we: 0x%01x", dut.opa_reg, dut.opa_we);
      $display("operand b: 0x%064x, opb_we: 0x%01x", dut.opb_reg, dut.opb_we);
      $display("product:   0x%0128x", dut.prod_reg);
      $display("");
    end
  endtask // dump_dut_state


  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut;
    begin
      $display("TB: Resetting dut.");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
      $display("");
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // display_test_results()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_results;
    begin
      $display("");
      if (error_ctr == 0)
        begin
          $display("%02d test completed. All test cases completed successfully.", tc_ctr);
        end
      else
        begin
          $display("%02d tests completed - %02d test cases did not complete successfully.",
                   tc_ctr, error_ctr);
        end
    end
  endtask // display_test_results


  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      cycle_ctr     = 0;
      error_ctr     = 0;
      tc_ctr        = 0;

      tb_clk        = 0;
      tb_reset_n    = 1;

      tb_cs         = 0;
      tb_we         = 0;
      tb_address    = 8'h0;
      tb_write_data = 16'h0;
    end
  endtask // init_sim


  //----------------------------------------------------------------
  // inc_tc_ctr
  //----------------------------------------------------------------
  task inc_tc_ctr;
    tc_ctr = tc_ctr + 1;
  endtask // inc_tc_ctr


  //----------------------------------------------------------------
  // inc_error_ctr
  //----------------------------------------------------------------
  task inc_error_ctr;
    error_ctr = error_ctr + 1;
  endtask // inc_error_ctr


  //----------------------------------------------------------------
  // write_word()
  //
  // Write the given word to the DUT using the DUT interface.
  //----------------------------------------------------------------
  task write_word(input [7 : 0] address, input [(API_WIDTH - 1) : 0] word);
    begin
      $display("*** Writing 0x%08x to 0x%02x.", word, address);
      $display("");

      tb_address = address;
      tb_write_data = word;
      tb_cs = 1;
      tb_we = 1;
      #(CLK_PERIOD);
      tb_cs = 0;
      tb_we = 0;
    end
  endtask // write_word


  //----------------------------------------------------------------
  // read_word()
  //
  // Read a data word from the given address in the DUT.
  // the word read will be available in the global variable
  // read_data.
  //----------------------------------------------------------------
  task read_word(input [11 : 0]  address);
    begin
      tb_address = address;
      tb_cs = 1;
      tb_we = 0;
      #(CLK_PERIOD);
      read_data = tb_read_data;
      tb_cs = 0;

      if (DEBUG)
        begin
          $display("*** Reading 0x%08x from 0x%02x.", read_data, address);
          $display("");
        end
    end
  endtask // read_word


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task tc1;
    begin
      $display("TC1: Writing data into operand registers:");

      write_word(8'h00, 16'hffff);
      write_word(8'h01, 16'hffff);
      write_word(8'h02, 16'hffff);
      write_word(8'h03, 16'hffff);

      write_word(8'h40, 16'hfffd);
      write_word(8'h41, 16'hffff);
      write_word(8'h42, 16'hffff);
      write_word(8'h43, 16'hffff);
      $display("");

      $display("TC1: Reading out data from product registers:");
      read_word(8'h80);
      read_word(8'h81);
      read_word(8'h82);
      read_word(8'h83);
      read_word(8'h84);
      read_word(8'h85);
      read_word(8'h86);
      read_word(8'h87);
    end
  endtask // tc1


  //----------------------------------------------------------------
  // main
  //----------------------------------------------------------------
  initial
    begin : main
      $display("*** Testbench for the multiplier started ***");
      $display("");

      init_sim();
      dump_dut_state();
      reset_dut();
      dump_dut_state();

      tc1();
      dump_dut_state();

      display_test_results();

      $display("*** Multiplier testbench done. ***");
      $finish;
    end // main

endmodule // tb_mult
