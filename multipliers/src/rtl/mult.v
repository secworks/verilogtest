//======================================================================
//
// mult.v
// --------
// Module for testing how multipliers are implemented in different
// technologies with different operand widths. The core has a 32 bit
// API to ensure that I/O are not constraining the implementation.
// Operands and products are registered.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2017 Assured AB
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

module mult(
            input wire                        clk,
            input wire                        reset_n,
            input wire                        cs,
            input wire                        we,
            input wire  [7 : 0]               addr,
            input wire  [(API_WIDTH - 1) : 0] write_data,
            output wire [(API_WIDTH - 1) : 0] read_data
           );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter API_WIDTH       = 16;
  parameter OPA_WIDTH       = 256;
  parameter OPB_WIDTH       = 64;

  localparam OPA_WORDS      = OPA_WIDTH / API_WIDTH;
  localparam OPA_BASE_ADDR  = 8'h00;
  localparam OPA_TOP_ADDR   = (OPA_BASE_ADDR + OPA_WORDS - 1);

  localparam OPB_WORDS      = OPB_WIDTH / API_WIDTH;
  localparam OPB_BASE_ADDR  = 8'h40;
  localparam OPB_TOP_ADDR   = (OPB_BASE_ADDR + OPB_WORDS - 1);

  localparam PROD_WIDTH     = OPA_WIDTH + OPB_WIDTH;
  localparam PROD_WORDS     = PROD_WIDTH / API_WIDTH;
  localparam PROD_BASE_ADDR = 8'h80;
  localparam PROD_TOP_ADDR  = (PROD_BASE_ADDR + PROD_WORDS - 1);


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [(OPA_WIDTH - 1) : 0] opa_reg;
  reg [(OPA_WIDTH - 1) : 0] opa_new;
  reg                       opa_we;

  reg [(OPA_WIDTH - 1) : 0] opb_reg;
  reg [(OPA_WIDTH - 1) : 0] opb_new;
  reg                       opb_we;

  reg [(PROD_WIDTH - 1) : 0] prod_reg;
  reg [(PROD_WIDTH - 1) : 0] prod_new;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [(API_WIDTH -1) : 0] tmp_read_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign read_data = tmp_read_data;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n)
        begin
          opa_reg  <= {(OPA_WIDTH){1'h0}};
          opb_reg  <= {(OPB_WIDTH){1'h0}};
          prod_reg <= {(PROD_WIDTH){1'h0}};
        end
      else
        begin
          prod_reg <= prod_new;

          if (opa_we)
            opa_reg <= opa_new;

          if (opb_we)
            opb_reg <= opb_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // mult_logic
  //
  // This is where the action is.
  //----------------------------------------------------------------
  always @*
    begin : mult_logic
      prod_new = opa_reg * opb_reg;
    end


  //----------------------------------------------------------------
  // api
  //
  // The interface command decoding logic.
  //----------------------------------------------------------------
  always @*
    begin : api
      tmp_read_data = {(API_WIDTH){1'h0}};
      opa_new       = opa_reg;
      opa_we        = 0;
      opb_new       = opb_reg;
      opb_we        = 0;

      if (cs)
        begin
          if (we)
            begin
              if ((addr >= OPA_BASE_ADDR) && (addr <= OPA_TOP_ADDR))
                begin
                  opa_new[API_WIDTH * (addr - OPA_BASE_ADDR) +: API_WIDTH] = write_data;
                  opa_we = 1;
                end

              if ((addr >= OPB_BASE_ADDR) && (addr <= OPB_TOP_ADDR))
                begin
                  opb_new[API_WIDTH * (addr - OPB_BASE_ADDR) +: API_WIDTH] = write_data;
                  opb_we = 1;
                end
            end

          else
            begin
              if ((addr >= PROD_BASE_ADDR) && (addr <= PROD_TOP_ADDR))
                tmp_read_data = prod_reg[API_WIDTH * (addr - PROD_BASE_ADDR) +: API_WIDTH];
            end
        end
    end // addr_decoder
endmodule // mult

//======================================================================
// EOF mult.v
//======================================================================
