// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// Author: Paul Scheffler <paulsc@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

module snitch_ssr import snitch_ssr_pkg::*; #(
  parameter ssr_cfg_t Cfg = '0,
  parameter int unsigned AddrWidth = 0,
  parameter int unsigned DataWidth = 0,
  parameter type tcdm_user_t  = logic,
  parameter type tcdm_req_t   = logic,
  parameter type tcdm_rsp_t   = logic,
  parameter type isect_slv_req_t = logic,
  parameter type isect_slv_rsp_t = logic,
  parameter type isect_mst_req_t = logic,
  parameter type isect_mst_rsp_t = logic,
  parameter type ssr_rdata_t = logic,
  /// Derived parameter *Do not override*
  parameter type addr_t = logic [AddrWidth-1:0],
  parameter type data_t = logic [DataWidth-1:0]
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  // Access to configuration registers (REG_BUS).
  input  logic  [4:0] cfg_word_i,
  input  logic        cfg_write_i,  // 0 = read, 1 = write
  output logic [31:0] cfg_rdata_o,
  input  logic [31:0] cfg_wdata_i,
  // Register lanes from switch.
  output ssr_rdata_t  lane_rdata_o, // Bundles zero and last flags
  input  data_t       lane_wdata_i,
  output logic        lane_valid_o,
  input  logic        lane_ready_i,
  // Ports into memory.
  output tcdm_req_t   mem_req_o,
  input  tcdm_rsp_t   mem_rsp_i,
  // Interface with intersector
  output isect_slv_req_t isect_slv_req_o,
  input  isect_slv_rsp_t isect_slv_rsp_i,
  output isect_mst_req_t isect_mst_req_o,
  input  isect_mst_rsp_t isect_mst_rsp_i,

  input  addr_t       tcdm_start_address_i
);

  data_t fifo_out, fifo_in;
  logic fifo_push, fifo_pop, fifo_full, fifo_empty;
  logic mover_valid;
  logic [$clog2(Cfg.DataCredits):0] credit_d, credit_q;
  logic has_credit, credit_take, credit_give;
  logic [Cfg.RptWidth-1:0] rep_max, rep_q, rep_done, rep_enable;
  logic agen_last, agen_zero;
  logic lane_last, lane_zero;

  fifo_v3 #(
    .FALL_THROUGH ( 0           ),
    .DATA_WIDTH   ( DataWidth   ),
    .DEPTH        ( Cfg.DataCredits )
  ) i_fifo (
    .clk_i,
    .rst_ni,
    .testmode_i ( 1'b0       ),
    .flush_i    ( '0         ),
    .full_o     ( fifo_full  ),
    .empty_o    ( fifo_empty ),
    .usage_o    (            ),
    .data_i     ( fifo_in    ),
    .push_i     ( fifo_push  ),
    .data_o     ( fifo_out   ),
    .pop_i      ( fifo_pop   )
  );

  logic data_req_qvalid;
  tcdm_req_t idx_req, data_req;
  tcdm_rsp_t idx_rsp, data_rsp;

  snitch_ssr_addr_gen #(
    .Cfg          ( Cfg         ),
    .AddrWidth    ( AddrWidth   ),
    .DataWidth    ( DataWidth   ),
    .tcdm_req_t   ( tcdm_req_t  ),
    .tcdm_rsp_t   ( tcdm_rsp_t  ),
    .tcdm_user_t  ( tcdm_user_t ),
    .isect_slv_req_t ( isect_slv_req_t ),
    .isect_slv_rsp_t ( isect_slv_rsp_t ),
    .isect_mst_req_t ( isect_mst_req_t ),
    .isect_mst_rsp_t ( isect_mst_rsp_t )
  ) i_addr_gen (
    .clk_i,
    .rst_ni,
    .idx_req_o      ( idx_req ),
    .idx_rsp_i      ( idx_rsp ),
    .isect_slv_req_o,
    .isect_slv_rsp_i,
    .isect_mst_req_o,
    .isect_mst_rsp_i,
    .cfg_word_i,
    .cfg_rdata_o,
    .cfg_wdata_i,
    .cfg_write_i,
    .reg_rep_o      ( rep_max           ),
    .mem_addr_o     ( data_req.q.addr   ),
    .mem_last_o     ( agen_last         ),
    .mem_zero_o     ( agen_zero         ),
    .mem_write_o    ( data_req.q.write  ),
    .mem_valid_o    ( mover_valid       ),
    .mem_ready_i    ( data_req_qvalid & data_rsp.q_ready ),
    .tcdm_start_address_i
  );

  if (Cfg.Indirection) begin : gen_demux
    tcdm_mux #(
      .NrPorts    ( 2             ),
      .AddrWidth  ( AddrWidth     ),
      .DataWidth  ( DataWidth     ),
      .user_t     ( tcdm_user_t   ),
      .RespDepth  ( Cfg.MuxRespDepth  ),
      .tcdm_req_t ( tcdm_req_t    ),
      .tcdm_rsp_t ( tcdm_rsp_t    )
    ) i_tcdm_mux (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( {idx_req, data_req} ),
      .slv_rsp_o  ( {idx_rsp, data_rsp} ),
      .mst_req_o  ( mem_req_o ),
      .mst_rsp_i  ( mem_rsp_i )
    );
  end else begin : gen_no_demux
    assign mem_req_o = data_req;
    assign data_rsp  = mem_rsp_i;
    // Tie off Index responses
    assign idx_rsp = '0;
  end

  assign data_req.q_valid = data_req_qvalid;
  assign data_req.q.amo = reqrsp_pkg::AMONone;
  assign data_req.q.user = '0;

  assign lane_rdata_o = '{data: fifo_out, zero: lane_zero, last: lane_last};
  assign data_req.q.data = fifo_out;
  assign data_req.q.strb = '1;

  always_comb begin
    if (data_req.q.write) begin
      lane_valid_o = ~fifo_full;
      data_req_qvalid = mover_valid & ~fifo_empty;
      fifo_push = lane_ready_i & ~fifo_full;
      fifo_in = lane_wdata_i;
      rep_enable = 0;
      fifo_pop = data_req_qvalid & data_rsp.q_ready;
      credit_take = fifo_push;
      credit_give = data_rsp.p_valid;
    end else begin
      lane_valid_o = ~fifo_empty;
      data_req_qvalid = mover_valid & ~fifo_full & has_credit;
      fifo_push = data_rsp.p_valid;
      fifo_in = data_rsp.p.data;
      rep_enable = lane_ready_i & ~fifo_empty;
      fifo_pop = rep_enable & rep_done & ~lane_zero;
      credit_take = data_req_qvalid & data_rsp.q_ready;
      credit_give = fifo_pop;
    end
  end

  if (Cfg.IsectMaster) begin : gen_isect_master
    logic meta_empty;
    // A metadata FIFO keeping the zero and last flags for in-flight reads only.
    fifo_v3 #(
      .FALL_THROUGH ( 0               ),
      .DATA_WIDTH   ( 2               ),
      .DEPTH        ( Cfg.DataCredits )
    ) i_fifo_meta (
      .clk_i,
      .rst_ni,
      .testmode_i ( 1'b0        ),
      .flush_i    ( '0          ),
      .full_o     (  ),
      .empty_o    ( meta_empty  ),
      .usage_o    (  ),
      .data_i     ( {agen_last, agen_zero} ),
      .push_i     ( credit_take & ~data_req.q.write ),
      .data_o     ( {lane_last, lane_zero} ),
      .pop_i      ( credit_give & ~meta_empty )
    );
  end else begin : gen_no_isect_master
    // If not an intersection master, we cannot track last items or inject zeros.
    assign lane_zero = 1'b0;
    assign lane_last = 1'b0;
  end

  // Credit counter that keeps track of the number of memory requests issued
  // to ensure that the FIFO does not overfill.
  always_comb begin
    credit_d = credit_q;
    if (credit_take & ~credit_give)
      credit_d = credit_q - 1;
    else if (!credit_take & credit_give)
      credit_d = credit_q + 1;
  end
  assign has_credit = (credit_q != '0);

  `FFARN(credit_q, credit_d, Cfg.DataCredits, clk_i, rst_ni)

  // Repetition counter.
  `FFLARNC(rep_q, rep_q + 1, rep_enable, rep_enable & rep_done, '0, clk_i, rst_ni)

  assign rep_done = (rep_q == rep_max);

endmodule
