`ifndef __SMTDV_TEST_COMMON_PKG_SV__
`define __SMTDV_TEST_COMMON_PKG_SV__

`timescale 1ns/10ps

package test_smtdv_common_pkg;

  import  uvm_pkg::*;
  `include "uvm_macros.svh"

  import smtdv_sqlite3_pkg::*;
  import smtdv_stl_pkg::*;

  import smtdv_common_pkg::*;
  `include "smtdv_macros.svh"

  import smtdv_common_seq_pkg::*;
  import smtdv_common_vseq_pkg::*;

// uvm standard tests
`include "smtdv_base_env.sv"
`include "smtdv_base_test.sv"
`include "smtdv_setup_test.sv"

// graph tests
`include "smtdv_directed_graph_test.sv"
//`include "smtdv_circular_graph_test.sv"
`include "smtdv_cmp_graph_test.sv"
//`include "smtdv_seq_graph_test.sv"
//`include "smtdv_top_graph_test.sv"

endpackage : test_smtdv_common_pkg

`endif // end of __SMTDV_TEST_COMMON_PKG_SV__
