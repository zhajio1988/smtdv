
`ifndef __APB_MASTER_SEQS_SV__
`define __APB_MASTER_SEQS_SV__

//typedef class apb_master_base_seq;
// bunch of physical sequences

class apb_master_1w_seq#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    apb_master_base_seq#(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  );

  typedef apb_master_1w_seq#(ADDR_WIDTH, DATA_WIDTH) seq_t;
  typedef apb_sequence_item#(ADDR_WIDTH, DATA_WIDTH) item_t;

  rand bit [ADDR_WIDTH-1:0] start_addr;
  rand int prio;
  bit blocking = TRUE;

  constraint c_prio { prio inside {[0:1]}; }

  `uvm_object_param_utils_begin(seq_t)
  `uvm_object_utils_end

  function new(string name = "apb_master_1w_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    super.body();
    item = item_t::type_id::create("item");
    `SMTDV_RAND_WITH(item,
      {
      mod_t == MASTER;
      trs_t == WR;
      run_t == FORCE;
      addr == start_addr;
      prio == prio;
      })

    `uvm_create(req)
    req.copy(item);
    start_item(req);
    finish_item(req);
    //if (blocking) get_response(rsp);
  endtask : body

endclass : apb_master_1w_seq


class apb_master_1r_seq#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    apb_master_base_seq#(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  );

  typedef apb_master_1r_seq#(ADDR_WIDTH, DATA_WIDTH) seq_t;
  typedef apb_sequence_item#(ADDR_WIDTH, DATA_WIDTH) item_t;

  rand bit [ADDR_WIDTH-1:0] start_addr;
  rand int prio;

  constraint c_prio { prio inside {[-1:0]}; }
  bit blocking = TRUE;

  `uvm_object_param_utils_begin(seq_t)
  `uvm_object_utils_end

  function new(string name = "apb_master_1r_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    super.body();
    item = item_t::type_id::create("item");
    `SMTDV_RAND_WITH(item,
      {
      mod_t == MASTER;
      trs_t == RD;
      run_t == FORCE;
      addr == start_addr;
      prio == prio;
      })

    `uvm_create(req)
    req.copy(item);
    start_item(req);
    finish_item(req);
    //if (blocking) get_response(rsp);
  endtask : body

endclass : apb_master_1r_seq



`endif // end of __APB_MASTER_SEQS_SV__
