// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "common_cells/assertions.svh"

module snitch_cluster_peripheral_reg_top #(
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic
) (
  input clk_i,
  input rst_ni,

  // Below Register interface can be changed
  input  reg_req_t reg_req_i,
  output reg_rsp_t reg_rsp_o,
  // To HW
  output snitch_cluster_peripheral_reg_pkg::snitch_cluster_peripheral_reg2hw_t reg2hw, // Write
  input  snitch_cluster_peripheral_reg_pkg::snitch_cluster_peripheral_hw2reg_t hw2reg, // Read

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import snitch_cluster_peripheral_reg_pkg::* ;

  localparam int AW = 6;
  localparam int DW = 64;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  reg_req_t reg_intf_req;
  reg_rsp_t reg_intf_rsp;

  assign reg_intf_req = reg_req_i;
  assign reg_rsp_o = reg_intf_rsp;

  assign reg_we = reg_intf_req.valid & reg_intf_req.write;
  assign reg_re = reg_intf_req.valid & ~reg_intf_req.write;
  assign reg_addr = reg_intf_req.addr;
  assign reg_wdata = reg_intf_req.wdata;
  assign reg_be = reg_intf_req.wstrb;
  assign reg_intf_rsp.rdata = reg_rdata;
  assign reg_intf_rsp.error = reg_error;
  assign reg_intf_rsp.ready = 1'b1;

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err ;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic perf_counter_enable_0_cycle_0_qs;
  logic perf_counter_enable_0_cycle_0_wd;
  logic perf_counter_enable_0_cycle_0_we;
  logic perf_counter_enable_0_tcdm_accessed_0_qs;
  logic perf_counter_enable_0_tcdm_accessed_0_wd;
  logic perf_counter_enable_0_tcdm_accessed_0_we;
  logic perf_counter_enable_0_tcdm_congested_0_qs;
  logic perf_counter_enable_0_tcdm_congested_0_wd;
  logic perf_counter_enable_0_tcdm_congested_0_we;
  logic perf_counter_enable_0_issue_fpu_0_qs;
  logic perf_counter_enable_0_issue_fpu_0_wd;
  logic perf_counter_enable_0_issue_fpu_0_we;
  logic perf_counter_enable_0_issue_fpu_seq_0_qs;
  logic perf_counter_enable_0_issue_fpu_seq_0_wd;
  logic perf_counter_enable_0_issue_fpu_seq_0_we;
  logic perf_counter_enable_0_issue_core_to_fpu_0_qs;
  logic perf_counter_enable_0_issue_core_to_fpu_0_wd;
  logic perf_counter_enable_0_issue_core_to_fpu_0_we;
  logic perf_counter_enable_1_cycle_1_qs;
  logic perf_counter_enable_1_cycle_1_wd;
  logic perf_counter_enable_1_cycle_1_we;
  logic perf_counter_enable_1_tcdm_accessed_1_qs;
  logic perf_counter_enable_1_tcdm_accessed_1_wd;
  logic perf_counter_enable_1_tcdm_accessed_1_we;
  logic perf_counter_enable_1_tcdm_congested_1_qs;
  logic perf_counter_enable_1_tcdm_congested_1_wd;
  logic perf_counter_enable_1_tcdm_congested_1_we;
  logic perf_counter_enable_1_issue_fpu_1_qs;
  logic perf_counter_enable_1_issue_fpu_1_wd;
  logic perf_counter_enable_1_issue_fpu_1_we;
  logic perf_counter_enable_1_issue_fpu_seq_1_qs;
  logic perf_counter_enable_1_issue_fpu_seq_1_wd;
  logic perf_counter_enable_1_issue_fpu_seq_1_we;
  logic perf_counter_enable_1_issue_core_to_fpu_1_qs;
  logic perf_counter_enable_1_issue_core_to_fpu_1_wd;
  logic perf_counter_enable_1_issue_core_to_fpu_1_we;
  logic [9:0] hart_select_hart_select_0_qs;
  logic [9:0] hart_select_hart_select_0_wd;
  logic hart_select_hart_select_0_we;
  logic [9:0] hart_select_hart_select_1_qs;
  logic [9:0] hart_select_hart_select_1_wd;
  logic hart_select_hart_select_1_we;
  logic [47:0] perf_counter_0_qs;
  logic [47:0] perf_counter_0_wd;
  logic perf_counter_0_we;
  logic [47:0] perf_counter_1_qs;
  logic [47:0] perf_counter_1_wd;
  logic perf_counter_1_we;
  logic [31:0] wake_up_wd;
  logic wake_up_we;
  logic [31:0] hw_barrier_qs;
  logic hw_barrier_re;

  // Register instances

  // Subregister 0 of Multireg perf_counter_enable
  // R[perf_counter_enable_0]: V(False)

  // F[cycle_0]: 0:0
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_cycle_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_cycle_0_we),
    .wd     (perf_counter_enable_0_cycle_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].cycle.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_cycle_0_qs)
  );


  // F[tcdm_accessed_0]: 1:1
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_tcdm_accessed_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_tcdm_accessed_0_we),
    .wd     (perf_counter_enable_0_tcdm_accessed_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].tcdm_accessed.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_tcdm_accessed_0_qs)
  );


  // F[tcdm_congested_0]: 2:2
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_tcdm_congested_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_tcdm_congested_0_we),
    .wd     (perf_counter_enable_0_tcdm_congested_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].tcdm_congested.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_tcdm_congested_0_qs)
  );


  // F[issue_fpu_0]: 3:3
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_issue_fpu_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_issue_fpu_0_we),
    .wd     (perf_counter_enable_0_issue_fpu_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].issue_fpu.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_issue_fpu_0_qs)
  );


  // F[issue_fpu_seq_0]: 4:4
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_issue_fpu_seq_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_issue_fpu_seq_0_we),
    .wd     (perf_counter_enable_0_issue_fpu_seq_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].issue_fpu_seq.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_issue_fpu_seq_0_qs)
  );


  // F[issue_core_to_fpu_0]: 5:5
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_0_issue_core_to_fpu_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_0_issue_core_to_fpu_0_we),
    .wd     (perf_counter_enable_0_issue_core_to_fpu_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[0].issue_core_to_fpu.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_0_issue_core_to_fpu_0_qs)
  );


  // Subregister 1 of Multireg perf_counter_enable
  // R[perf_counter_enable_1]: V(False)

  // F[cycle_1]: 0:0
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_cycle_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_cycle_1_we),
    .wd     (perf_counter_enable_1_cycle_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].cycle.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_cycle_1_qs)
  );


  // F[tcdm_accessed_1]: 1:1
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_tcdm_accessed_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_tcdm_accessed_1_we),
    .wd     (perf_counter_enable_1_tcdm_accessed_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].tcdm_accessed.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_tcdm_accessed_1_qs)
  );


  // F[tcdm_congested_1]: 2:2
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_tcdm_congested_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_tcdm_congested_1_we),
    .wd     (perf_counter_enable_1_tcdm_congested_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].tcdm_congested.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_tcdm_congested_1_qs)
  );


  // F[issue_fpu_1]: 3:3
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_issue_fpu_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_issue_fpu_1_we),
    .wd     (perf_counter_enable_1_issue_fpu_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].issue_fpu.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_issue_fpu_1_qs)
  );


  // F[issue_fpu_seq_1]: 4:4
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_issue_fpu_seq_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_issue_fpu_seq_1_we),
    .wd     (perf_counter_enable_1_issue_fpu_seq_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].issue_fpu_seq.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_issue_fpu_seq_1_qs)
  );


  // F[issue_core_to_fpu_1]: 5:5
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_perf_counter_enable_1_issue_core_to_fpu_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_enable_1_issue_core_to_fpu_1_we),
    .wd     (perf_counter_enable_1_issue_core_to_fpu_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter_enable[1].issue_core_to_fpu.q ),

    // to register interface (read)
    .qs     (perf_counter_enable_1_issue_core_to_fpu_1_qs)
  );




  // Subregister 0 of Multireg hart_select
  // R[hart_select]: V(False)

  // F[hart_select_0]: 9:0
  prim_subreg #(
    .DW      (10),
    .SWACCESS("RW"),
    .RESVAL  (10'h0)
  ) u_hart_select_hart_select_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (hart_select_hart_select_0_we),
    .wd     (hart_select_hart_select_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.hart_select[0].q ),

    // to register interface (read)
    .qs     (hart_select_hart_select_0_qs)
  );


  // F[hart_select_1]: 19:10
  prim_subreg #(
    .DW      (10),
    .SWACCESS("RW"),
    .RESVAL  (10'h0)
  ) u_hart_select_hart_select_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (hart_select_hart_select_1_we),
    .wd     (hart_select_hart_select_1_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.hart_select[1].q ),

    // to register interface (read)
    .qs     (hart_select_hart_select_1_qs)
  );




  // Subregister 0 of Multireg perf_counter
  // R[perf_counter_0]: V(False)

  prim_subreg #(
    .DW      (48),
    .SWACCESS("RW"),
    .RESVAL  (48'h0)
  ) u_perf_counter_0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_0_we),
    .wd     (perf_counter_0_wd),

    // from internal hardware
    .de     (hw2reg.perf_counter[0].de),
    .d      (hw2reg.perf_counter[0].d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter[0].q ),

    // to register interface (read)
    .qs     (perf_counter_0_qs)
  );

  // Subregister 1 of Multireg perf_counter
  // R[perf_counter_1]: V(False)

  prim_subreg #(
    .DW      (48),
    .SWACCESS("RW"),
    .RESVAL  (48'h0)
  ) u_perf_counter_1 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (perf_counter_1_we),
    .wd     (perf_counter_1_wd),

    // from internal hardware
    .de     (hw2reg.perf_counter[1].de),
    .d      (hw2reg.perf_counter[1].d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.perf_counter[1].q ),

    // to register interface (read)
    .qs     (perf_counter_1_qs)
  );


  // R[wake_up]: V(True)

  prim_subreg_ext #(
    .DW    (32)
  ) u_wake_up (
    .re     (1'b0),
    .we     (wake_up_we),
    .wd     (wake_up_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.wake_up.qe),
    .q      (reg2hw.wake_up.q ),
    .qs     ()
  );


  // R[hw_barrier]: V(True)

  prim_subreg_ext #(
    .DW    (32)
  ) u_hw_barrier (
    .re     (hw_barrier_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.hw_barrier.d),
    .qre    (),
    .qe     (),
    .q      (reg2hw.hw_barrier.q ),
    .qs     (hw_barrier_qs)
  );




  logic [6:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_PERF_COUNTER_ENABLE_0_OFFSET);
    addr_hit[1] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_PERF_COUNTER_ENABLE_1_OFFSET);
    addr_hit[2] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_HART_SELECT_OFFSET);
    addr_hit[3] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_PERF_COUNTER_0_OFFSET);
    addr_hit[4] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_PERF_COUNTER_1_OFFSET);
    addr_hit[5] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_WAKE_UP_OFFSET);
    addr_hit[6] = (reg_addr == SNITCH_CLUSTER_PERIPHERAL_HW_BARRIER_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = 1'b0;
    if (addr_hit[0] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[0] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[0] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[1] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[1] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[1] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[2] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[2] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[2] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[3] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[3] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[3] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[4] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[4] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[4] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[5] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[5] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[5] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[6] && reg_we && (SNITCH_CLUSTER_PERIPHERAL_PERMIT[6] != (SNITCH_CLUSTER_PERIPHERAL_PERMIT[6] & reg_be))) wr_err = 1'b1 ;
  end

  assign perf_counter_enable_0_cycle_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_cycle_0_wd = reg_wdata[0];

  assign perf_counter_enable_0_tcdm_accessed_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_tcdm_accessed_0_wd = reg_wdata[1];

  assign perf_counter_enable_0_tcdm_congested_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_tcdm_congested_0_wd = reg_wdata[2];

  assign perf_counter_enable_0_issue_fpu_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_issue_fpu_0_wd = reg_wdata[3];

  assign perf_counter_enable_0_issue_fpu_seq_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_issue_fpu_seq_0_wd = reg_wdata[4];

  assign perf_counter_enable_0_issue_core_to_fpu_0_we = addr_hit[0] & reg_we & ~wr_err;
  assign perf_counter_enable_0_issue_core_to_fpu_0_wd = reg_wdata[5];

  assign perf_counter_enable_1_cycle_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_cycle_1_wd = reg_wdata[0];

  assign perf_counter_enable_1_tcdm_accessed_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_tcdm_accessed_1_wd = reg_wdata[1];

  assign perf_counter_enable_1_tcdm_congested_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_tcdm_congested_1_wd = reg_wdata[2];

  assign perf_counter_enable_1_issue_fpu_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_issue_fpu_1_wd = reg_wdata[3];

  assign perf_counter_enable_1_issue_fpu_seq_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_issue_fpu_seq_1_wd = reg_wdata[4];

  assign perf_counter_enable_1_issue_core_to_fpu_1_we = addr_hit[1] & reg_we & ~wr_err;
  assign perf_counter_enable_1_issue_core_to_fpu_1_wd = reg_wdata[5];

  assign hart_select_hart_select_0_we = addr_hit[2] & reg_we & ~wr_err;
  assign hart_select_hart_select_0_wd = reg_wdata[9:0];

  assign hart_select_hart_select_1_we = addr_hit[2] & reg_we & ~wr_err;
  assign hart_select_hart_select_1_wd = reg_wdata[19:10];

  assign perf_counter_0_we = addr_hit[3] & reg_we & ~wr_err;
  assign perf_counter_0_wd = reg_wdata[47:0];

  assign perf_counter_1_we = addr_hit[4] & reg_we & ~wr_err;
  assign perf_counter_1_wd = reg_wdata[47:0];

  assign wake_up_we = addr_hit[5] & reg_we & ~wr_err;
  assign wake_up_wd = reg_wdata[31:0];

  assign hw_barrier_re = addr_hit[6] && reg_re;

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = perf_counter_enable_0_cycle_0_qs;
        reg_rdata_next[1] = perf_counter_enable_0_tcdm_accessed_0_qs;
        reg_rdata_next[2] = perf_counter_enable_0_tcdm_congested_0_qs;
        reg_rdata_next[3] = perf_counter_enable_0_issue_fpu_0_qs;
        reg_rdata_next[4] = perf_counter_enable_0_issue_fpu_seq_0_qs;
        reg_rdata_next[5] = perf_counter_enable_0_issue_core_to_fpu_0_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = perf_counter_enable_1_cycle_1_qs;
        reg_rdata_next[1] = perf_counter_enable_1_tcdm_accessed_1_qs;
        reg_rdata_next[2] = perf_counter_enable_1_tcdm_congested_1_qs;
        reg_rdata_next[3] = perf_counter_enable_1_issue_fpu_1_qs;
        reg_rdata_next[4] = perf_counter_enable_1_issue_fpu_seq_1_qs;
        reg_rdata_next[5] = perf_counter_enable_1_issue_core_to_fpu_1_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[9:0] = hart_select_hart_select_0_qs;
        reg_rdata_next[19:10] = hart_select_hart_select_1_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[47:0] = perf_counter_0_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[47:0] = perf_counter_1_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = hw_barrier_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // Assertions for Register Interface

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit))


endmodule
