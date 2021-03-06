
`ifndef __SMTDV_TEST_SV__
`define __SMTDV_TEST_SV__

typedef class smtdv_timeout_cb;
typedef class smtdv_report_server;
typedef class smtdv_component;

/**
* smtdv_test
*
* extends smtdv_component
*
* @class smtdv_test
*
*/
class smtdv_test
  extends
  smtdv_component#(uvm_test);

  typedef smtdv_test test_t;

  bit has_debug = TRUE;

  smtdv_timeout_cb tout_cb;
  uvm_table_printer tbprt;

  `uvm_component_param_utils_begin(test_t)
  `uvm_component_utils_end

  function new(string name = "smtdv_test", uvm_component parent=null);
    super.new(name, parent);
    tbprt = new();
  endfunction : new

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);

endclass : smtdv_test


function void smtdv_test::build_phase(uvm_phase phase);
  smtdv_report_server          rpt_svr;
  uvm_report_global_server     glb_rpt_svr;
  smtdv_print_mask_t           print_mask  = SMTDV_ALL_ON,
  no_filename = SMTDV_ALL_ON,
  no_line     = SMTDV_ALL_ON,
  no_time     = SMTDV_ALL_ON,
  no_name     = SMTDV_ALL_ON,
  no_id       = SMTDV_ALL_ON;

  super.build_phase(phase);

  tout_cb= smtdv_timeout_cb::type_id::create("tout_cb");
  uvm_report_cb::add(null, tout_cb);

  // Replace the default report server by smtdv_report_server
  rpt_svr= new();
  glb_rpt_svr= new();
  glb_rpt_svr.set_server(rpt_svr);

  if($test$plusargs("SMTDV_NO_FILENAME"))
    no_filename= SMTDV_NO_FILENAME;
  if($test$plusargs("SMTDV_NO_LINE"))
    no_line= SMTDV_NO_LINE;
  if($test$plusargs("SMTDV_NO_TIME"))
    no_time= SMTDV_NO_TIME;
  if($test$plusargs("SMTDV_NO_NAME"))
    no_name= SMTDV_NO_NAME;
  if($test$plusargs("SMTDV_NO_ID"))
    no_id= SMTDV_NO_ID;

  print_mask= smtdv_print_mask_t'(no_filename & no_line & no_time & no_name & no_id);

  rpt_svr.set_display_mode(print_mask);

  smtdv_label_handler::register(this);
endfunction : build_phase


task smtdv_test::run_phase(uvm_phase phase);
  super.run_phase(phase);

  fork
    super.run_phase(phase);
    tout_cb.m_run_ph= phase;
    tbprt.knobs.depth = 5;
    this.print(tbprt);
    uvm_report_object::set_report_max_quit_count(2);  // set max error quit counts
    phase.phase_done.set_drain_time(this, 1000);      // set the extend $finish time when the all trxs are done
  join_none

  smtdv_label_handler::run();
endtask : run_phase

function void smtdv_test::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);

  smtdv_label_handler::finalize();
endfunction : end_of_elaboration_phase

`endif // end of __SMTDV_TEST_SV__
