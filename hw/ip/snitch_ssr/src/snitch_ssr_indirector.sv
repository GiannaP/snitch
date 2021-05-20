// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Paul Scheffler <paulsc@iis.ee.ethz.ch>

// Indirection datapath for the SSR address generator.

`include "common_cells/registers.svh"
`include "common_cells/assertions.svh"

module snitch_ssr_indirector import snitch_ssr_pkg::*; #(
  parameter ssr_cfg_t Cfg = '0,
  parameter int unsigned AddrWidth = 0,
  parameter int unsigned DataWidth = 0,
  parameter type tcdm_req_t   = logic,
  parameter type tcdm_rsp_t   = logic,
  parameter type tcdm_user_t  = logic,
  parameter type isect_slv_req_t = logic,
  parameter type isect_slv_rsp_t = logic,
  parameter type isect_mst_req_t = logic,
  parameter type isect_mst_rsp_t = logic,
  /// Derived parameters *Do not override*
  parameter int unsigned BytecntWidth = $clog2(DataWidth/8),
  parameter type addr_t     = logic [AddrWidth-1:0],
  parameter type data_t     = logic [DataWidth-1:0],
  parameter type bytecnt_t  = logic [BytecntWidth-1:0],
  parameter type index_t    = logic [Cfg.IndexWidth-1:0],
  parameter type pointer_t  = logic [Cfg.PointerWidth-1:0],
  parameter type shift_t    = logic [Cfg.ShiftWidth-1:0],
  parameter type idx_size_t = logic [$clog2($clog2(DataWidth/8)+1)-1:0]
) (
  input  logic      clk_i,
  input  logic      rst_ni,
  // Index fetch ports
  output tcdm_req_t idx_req_o,
  input  tcdm_rsp_t idx_rsp_i,
  // With intersector interfaces
  output isect_slv_req_t isect_slv_req_o,
  input  isect_slv_rsp_t isect_slv_rsp_i,
  output isect_mst_req_t isect_mst_req_o,
  input  isect_mst_rsp_t isect_mst_rsp_i,
  // From config interface
  input  bytecnt_t  cfg_offs_next_i,
  input  logic      cfg_done_i,
  input  logic      cfg_indir_i,
  input  logic      cfg_isect_slv_i,    // Whether to consume indices from intersector
  input  logic      cfg_isect_mst_i,    // Whether to emit indices to intersector
  input  logic      cfg_isect_merge_i,  // Whether to form union instead of intersection
  input  idx_size_t cfg_size_i,
  input  pointer_t  cfg_base_i,
  input  shift_t    cfg_shift_i,
  // With natural iterator level 0 (upstream)
  input  pointer_t  natit_pointer_i,
  output logic      natit_ready_o,
  input  logic      natit_done_i,       // Keep high, deassert with cfg_done_i
  input  bytecnt_t  natit_boundoffs_i,  // Additional byte offset incurred by subword bound
  output logic      natit_extraword_o,  // Emit additional index word address if bounds require it
  // To address generator output (downstream)
  output pointer_t  mem_pointer_o,
  output logic      mem_last_o,
  output logic      mem_zero_o,         // Whether to inject a zero value; overrules pointer!
  output logic      mem_valid_o,
  input  logic      mem_ready_i,
  // TCDM base
  input  addr_t     tcdm_start_address_i
);

  // Index FIFO signals
  logic idx_fifo_empty;
  logic idx_fifo_pop;
  data_t idx_fifo_out;

  // Index credit counter
  logic [$clog2(Cfg.IndexCredits):0] idx_cred_d, idx_cred_q;
  logic idx_cred_take, idx_cred_give;
  logic idx_cred_left;

  // Last word & index tracking
  logic last_word;
  bytecnt_t first_idx_byteoffs;
  bytecnt_t last_idx_byteoffs;

  // Index serializer
  data_t  idx_ser_mask;
  index_t idx_ser_out;
  logic   idx_ser_last;
  logic   idx_ser_valid;
  logic   idx_ser_ready;

  // Post-intersector slave stream
  index_t isect_slv_idx;
  logic   isect_slv_last;
  logic   isect_slv_valid;
  logic   isect_slv_ready;

  // Index serializer counter
  logic     idx_bytecnt_ena;
  bytecnt_t idx_bytecnt_d, idx_bytecnt_q;
  bytecnt_t idx_bytecnt_next;

  // Index TCDM request (read-only)
  assign idx_req_o.q = '{
      // Mask lower bits to fetch only entire, aligned words
      addr: {tcdm_start_address_i[AddrWidth-1:Cfg.PointerWidth],
          natit_pointer_i[Cfg.PointerWidth-1:BytecntWidth], {BytecntWidth{1'b0}}},
      default: '0
    };

  // Index handshaking
  assign idx_req_o.q_valid  = cfg_indir_i & idx_cred_left & ~natit_done_i;
  assign natit_ready_o      = cfg_indir_i & idx_cred_left & idx_rsp_i.q_ready;

  // Index FIFO: stores full unserialized words.
  fifo_v3 #(
    .FALL_THROUGH ( 1'b0              ),
    .DATA_WIDTH   ( DataWidth         ),
    .DEPTH        ( Cfg.IndexCredits  )
  ) i_idx_fifo (
    .clk_i,
    .rst_ni,
    .flush_i    ( 1'b0              ),
    .testmode_i ( 1'b0              ),
    .full_o     (  ),                     // Credit counter prevents overflows
    .empty_o    ( idx_fifo_empty    ),
    .usage_o    (  ),
    .data_i     ( idx_rsp_i.p.data  ),
    .push_i     ( idx_rsp_i.p_valid ),
    .data_o     ( idx_fifo_out      ),
    .pop_i      ( idx_fifo_pop      )
  );

  // Credit counter that keeps track of the number of memory requests in flight
  // to ensure that the FIFO does not overfill.
  always_comb begin
    idx_cred_d = idx_cred_q;
    if (idx_cred_take & ~idx_cred_give)       idx_cred_d = idx_cred_q - 1;
    else if (~idx_cred_take & idx_cred_give)  idx_cred_d = idx_cred_q + 1;
  end

  `FFARN(idx_cred_q, idx_cred_d, Cfg.IndexCredits, clk_i, rst_ni)

  assign idx_cred_left = (idx_cred_q != '0);
  assign idx_cred_take = idx_req_o.q_valid & idx_rsp_i.q_ready;
  assign idx_cred_give = idx_fifo_pop;

  // The initial byte offset and byte offset of the index array bound determine
  // the final index offset and whether an additional index word is needed.
  assign last_word          = (idx_cred_q == Cfg.IndexCredits-1) & natit_done_i;
  assign first_idx_byteoffs = bytecnt_t'(natit_pointer_i);
  assign {natit_extraword_o, last_idx_byteoffs} = first_idx_byteoffs + natit_boundoffs_i;

  // Serialize indices: shift left by current byte offset, then mask out index of given size.
  assign idx_ser_mask   = ~({DataWidth{1'b1}} << (8 << cfg_size_i));
  assign idx_ser_out    = (idx_fifo_out >> (BytecntWidth+3)'(idx_bytecnt_q << 3)) & idx_ser_mask;
  assign idx_ser_last   = last_word & idx_fifo_pop;
  assign idx_ser_valid  = ~idx_fifo_empty;

  // Ensure intersection modes match capabilities
  `ASSERT_NEVER(no_isect_slave_cfg, ~Cfg.IsectSlave & cfg_isect_slv_i, clk_i, !rst_ni)
  `ASSERT_NEVER(no_isect_master_cfg, ~Cfg.IsectMaster & cfg_isect_slv_i, clk_i, !rst_ni)

  // Output index depends on whether we consume from serializer or intersected stream
  always_comb begin
    if (Cfg.IsectSlave & cfg_isect_slv_i) begin
      isect_slv_req_o = '{ena: cfg_isect_slv_i, ready: isect_slv_ready};
      idx_ser_ready   = 1'b0;
      isect_slv_idx   = isect_slv_rsp_i.idx;
      isect_slv_last  = isect_slv_rsp_i.last;
      isect_slv_valid = isect_slv_rsp_i.valid;
    end else begin
      isect_slv_req_o = '0;
      idx_ser_ready   = isect_slv_ready;
      isect_slv_idx   = idx_ser_out;
      isect_slv_last  = idx_ser_last;
      isect_slv_valid = idx_ser_valid;
    end
  end

  // Output validity and zero flag depend on whether we emit indices to intersect
  // TODO: Check if switching power of isect_mst_req_o is worth the masking area / path delay
  always_comb begin
    if (Cfg.IsectMaster & cfg_isect_mst_i) begin
      isect_mst_req_o = '{merge: cfg_isect_merge_i, idx: idx_ser_out,
                          last: idx_ser_last, valid: idx_ser_valid & mem_ready_i};
      isect_slv_ready = isect_mst_rsp_i.ready;
      mem_zero_o      = isect_mst_rsp_i.zero;
      mem_last_o      = isect_mst_rsp_i.last;
      mem_valid_o     = isect_mst_req_o.valid & isect_mst_rsp_i.ready;
    end else begin
      isect_mst_req_o = '0;
      isect_slv_ready = mem_ready_i;
      mem_zero_o      = 1'b0;
      mem_last_o      = isect_slv_last;
      mem_valid_o     = isect_slv_valid;
    end
  end

  // Shift and emit indices
  assign mem_pointer_o = cfg_base_i + ((pointer_t'(isect_slv_idx) << BytecntWidth) << cfg_shift_i);

  // Serializer counter advancing the byte offset
  always_comb begin
    idx_bytecnt_d = idx_bytecnt_q;
    // Set the initial byte offset (upbeat) before job starts, i.e. while done register set.
    if (cfg_done_i)           idx_bytecnt_d = cfg_offs_next_i;
    else if (idx_bytecnt_ena) idx_bytecnt_d = idx_bytecnt_next;
  end

  `FFARN(idx_bytecnt_q, idx_bytecnt_d, '0, clk_i, rst_ni)

  assign idx_bytecnt_next = idx_bytecnt_q + bytecnt_t'(1 << cfg_size_i);

  // Move on to next FIFO word if not stalled and at last index in word
  assign idx_fifo_pop = idx_bytecnt_ena &
      (last_word ? idx_bytecnt_q == last_idx_byteoffs : idx_bytecnt_next == '0);

  // Serialize whenever words are available and downstream ready and no zero inject
  assign idx_bytecnt_ena  = ~idx_fifo_empty & idx_ser_ready & ~mem_zero_o;

endmodule
