
`ifndef __APB_SLAVE_IRQ_SEQ_SV__
`define __APB_SLAVE_IRQ_SEQ_SV__

//typedef class apb_slave_base_seq;
//typedef class apb_sequence_item;


class apb_slave_irq_seq#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
  apb_slave_base_seq#(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  );

  bit [DATA_WIDTH-1:0] data;
  static bit [DATA_WIDTH-1:0] irq_data = 'hdead;

  typedef apb_slave_irq_seq#(ADDR_WIDTH, DATA_WIDTH) seq_t;
  typedef apb_sequence_item#(ADDR_WIDTH, DATA_WIDTH) item_t;

  item_t ritem;

  `uvm_object_param_utils_begin(seq_t)
  `uvm_object_utils_end

  function new(string name = "apb_slave_irq_seq");
    super.new(name);
  endfunction : new

  virtual task do_drive_irq();
    forever begin
      data = ritem.unpack_data(0);

      if (data == irq_data) begin
        seqr.vif.slave.pirq <= 1'b1;
        `uvm_info(get_type_name(), {"GET AFTER IRQ\n"}, UVM_LOW)
      end

      @(posedge seqr.vif.clk);
      seqr.vif.slave.pirq <= 1'b0;
    end
  endtask : do_drive_irq

  virtual task pre_do_write_item(item_t item);
    super.pre_do_write_item(item);
    ritem = item;

    fork
      do_drive_irq();
    join_none
  endtask : pre_do_write_item

endclass : apb_slave_irq_seq

`endif // __APB_SLAVE_IRQ_SEQ_SV__

