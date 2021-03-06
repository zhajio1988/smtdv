

`ifndef __AHB_MASTER_BASE_VSEQ_SV__
`define __AHB_MASTER_BASE_VSEQ_SV__

typedef class ahb_virtual_sequencer;

// bind virtual sequencer as physical sequencer
class ahb_master_base_vseq
  extends
  smtdv_master_base_vseq;

  typedef ahb_master_base_vseq vseq_t;
  typedef ahb_virtual_sequencer vseqr_t;

  vseqr_t vseqr;

  `uvm_object_param_utils_begin(vseq_t)
  `uvm_object_utils_end

  `uvm_declare_p_sequencer(vseqr_t)

  function new(string name = "ahb_master_base_vseq");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    super.pre_body();
    if (!$cast(vseqr, this.get_sequencer()))
      `uvm_error("SMTDV_UCAST_V/PSEQR",
         {$psprintf("UP CAST TO SMTDV V/PSEQR FAIL")})

    seq_blder._create_seq_graph();
  endtask : pre_body

endclass : ahb_master_base_vseq

`endif // __AHB_MASTER_BASE_VSEQ_SV__

