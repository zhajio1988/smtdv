
`ifndef __UART_RX_DRIVER_THREADS_SV__
`define __UART_RX_DRIVER_THREADS_SV__

typedef class uart_item;
typedef class uart_rx_driver;

class uart_rx_base_thread#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    smtdv_run_thread#(
      uart_rx_driver#(ADDR_WIDTH, DATA_WIDTH)
  );

  typedef uart_rx_base_thread#(ADDR_WIDTH, DATA_WIDTH) th_t;
  typedef uart_item#(ADDR_WIDTH, DATA_WIDTH) item_t;
  typedef uart_rx_driver#(ADDR_WIDTH, DATA_WIDTH) cmp_t;

  item_t item;

  `uvm_object_param_utils_begin(th_t)
  `uvm_object_utils_end

  function new(string name = "uart_rx_base_thread", cmp_t parent=null);
    super.new(name, parent);
  endfunction : new

  virtual function void pre_do();
    if (!this.cmp) begin
      `uvm_fatal("UART_NO_CMP",{"CMP MUST BE SET ",get_full_name(),".cmp"});
    end
  endfunction : pre_do

endclass : uart_rx_base_thread


class uart_rx_sample_rate#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    uart_rx_base_thread#(
      ADDR_WIDTH,
      DATA_WIDTH
  );

  typedef uart_rx_sample_rate#(ADDR_WIDTH, DATA_WIDTH) th_t;

  `uvm_object_param_utils_begin(th_t)
  `uvm_object_utils_end

  function new(string name = "uart_rx_sample_rate", cmp_t parent=null);
    super.new(name, parent);
  endfunction : new

  virtual task run();
    forever begin
      @(posedge this.cmp.vif.clk);
      if (!this.cmp.vif.resetn) begin
        this.cmp.ua_brgr = 0;
        this.cmp.sample_clk = 0;
      end else begin
        if (this.cmp.ua_brgr == ({this.cmp.cfg.baud_rate_div, this.cmp.cfg.baud_rate_gen})) begin
          this.cmp.ua_brgr = 0;
          this.cmp.sample_clk = 1;
        end else begin
          this.cmp.sample_clk = 0;
          this.cmp.ua_brgr++;
        end
      end
    end
  endtask : run

endclass : uart_rx_sample_rate


class uart_rx_drive_items#(
  ADDR_WIDTH = 14,
  DATA_WIDTH = 32
  ) extends
    uart_rx_base_thread#(
      ADDR_WIDTH,
      DATA_WIDTH
  );

  typedef uart_rx_drive_items#(ADDR_WIDTH, DATA_WIDTH) th_t;

  `uvm_object_param_utils_begin(th_t)
  `uvm_object_utils_end

  function new(string name = "uart_rx_drive_items", cmp_t parent=null);
    super.new(name, parent);
  endfunction : new

  virtual task run();
    bit bb;

    forever begin
      this.cmp.mbox.get(item);
      this.cmp.num_items_sent++;

      `uvm_info(this.cmp.get_full_name(),
            $psprintf("Driver Sending RX Item No:%0d...\n%s", this.cmp.num_items_sent, item.sprint()),
            UVM_HIGH)

      this.cmp.num_of_bits_sent = 0;

      if(this.cmp.cfg.block_req) begin repeat (item.transmit_delay) @(posedge this.cmp.vif.clk); end

      wait((!this.cmp.cfg.rts_en)||(!this.cmp.vif.cts_n));
      `uvm_info(this.cmp.get_full_name(), "Driver - Modem RTS or CTS asserted", UVM_HIGH)

      while (this.cmp.num_of_bits_sent <= (1 + this.cmp.cfg.char_len_val + this.cmp.cfg.parity_en + this.cmp.cfg.nbstop)) begin
        @(posedge this.cmp.vif.clk);
      #1;
        if (this.cmp.sample_clk) begin
          if (this.cmp.num_of_bits_sent == 0) begin
            // Start sending rx_item with "start bit"
            this.cmp.vif.rx.rxd <= item.start_bit;
            `uvm_info(this.cmp.get_full_name(),
                      $psprintf("Driver Sending item SOP: %b", item.start_bit),
                      UVM_HIGH)
          end
          if ((this.cmp.num_of_bits_sent > 0) && (this.cmp.num_of_bits_sent < (1 + this.cmp.cfg.char_len_val))) begin
            // sending "data bits"
            bb = item.unpack_data(this.cmp.num_of_bits_sent-1);
            this.cmp.vif.rx.rxd <= item.unpack_data(this.cmp.num_of_bits_sent-1);
            `uvm_info(this.cmp.get_full_name(),
                 $psprintf("Driver Sending item data bit number:%0d value:'b%b",
                 (this.cmp.num_of_bits_sent-1), bb), UVM_HIGH)
          end
          if ((this.cmp.num_of_bits_sent == (1 + this.cmp.cfg.char_len_val)) && (this.cmp.cfg.parity_en)) begin
            // sending "parity bit" if parity is enabled
            this.cmp.vif.rx.rxd <= item.calc_parity(this.cmp.cfg.char_len_val, this.cmp.cfg.parity_mode);
            `uvm_info(this.cmp.get_full_name(),
                 $psprintf("Driver Sending item Parity bit:'b%b",
                 item.calc_parity(this.cmp.cfg.char_len_val, this.cmp.cfg.parity_mode)), UVM_HIGH)
          end
          if (this.cmp.num_of_bits_sent == (1 + this.cmp.cfg.char_len_val + this.cmp.cfg.parity_en)) begin
            // sending "stop/error bits"
            for (int i = 0; i < this.cmp.cfg.nbstop; i++) begin
              `uvm_info(this.cmp.get_full_name(),
                   $psprintf("Driver Sending item Stop bit:'b%b",
                   item.stop_bits[i]), UVM_HIGH)
              wait (this.cmp.sample_clk);
              if (item.error_bits[i]) begin
                this.cmp.vif.rx.rxd <= 0;
                `uvm_info(this.cmp.get_full_name(),
                     $psprintf("Driver intensionally corrupting Stop bit since error_bits['b%b] is 'b%b", i, item.error_bits[i]),
                     UVM_HIGH)
              end else
              this.cmp.vif.rx.rxd <= item.stop_bits[i];

              this.cmp.num_of_bits_sent++;
              wait (!this.cmp.sample_clk);
            end
          end
        this.cmp.num_of_bits_sent++;
        wait (!this.cmp.sample_clk);
        end
      end

      `uvm_info(this.cmp.get_full_name(),
           $psprintf("item **%0d** Sent...", this.cmp.num_items_sent), UVM_MEDIUM)
      wait (this.cmp.sample_clk);
      this.cmp.vif.rx.rxd <= 1;

      `uvm_info(this.cmp.get_full_name(), "item complete...", UVM_MEDIUM)
    end
  endtask : run

endclass : uart_rx_drive_items

`endif // __UART_RX_DRIVER_THREADS_SV__
