
`ifndef __APB_MASTER_CFG_SEQ_SV__
`define __APB_MASTER_CFG_SEQ_SV__

//typedef class apb_sequence_item;
//typedef class apb_master_cfg;
//typedef class apb_master_sequencer;

class apb_master_cfg_seq#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    apb_master_base_seq#(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  );

  typedef apb_master_cfg_seq#(ADDR_WIDTH, DATA_WIDTH) seq_t;
  typedef apb_sequence_item#(ADDR_WIDTH, DATA_WIDTH) item_t;

  rand bit [ADDR_WIDTH-1:0] start_addr;
  rand bit [DATA_WIDTH-1:0] write_data;
  bit blocking = TRUE;

  `uvm_object_param_utils_begin(seq_t)
  `uvm_object_utils_end

  function new(string name = "apb_master_cfg_seq");
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
      })
    item.pack_data(0, write_data);

    `uvm_create(req)
    req.copy(item);
    start_item(req);
    finish_item(req);
    //if (blocking) get_response(rsp);
  endtask : body

endclass : apb_master_cfg_seq

`endif // __APB_MASTER_CFG_SEQ_SV__
