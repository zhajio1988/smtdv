
// as generic memory cb func
class smtdv_generic_memory_cb#(GENE_MEM_ADDR_WIDTH = 64)
  extends
  uvm_object;

  typedef bit [(GENE_MEM_ADDR_WIDTH-1):0] gene_mem_addr_t;
  typedef bit [15:0][7:0] byte16_t;

  string attr_longint[$] = `SMTDV_MEM_VIF_ATTR_LONGINT
  string table_nm = "";

  function new(string name="smtdv_generic_memory_cb");
    super.new(name);
  endfunction

  virtual function create_table();
    if (table_nm == "")begin
       `uvm_fatal("NOTBNM", {$psprintf("set table name at generic_mem cb")})
    end
    table_nm = $psprintf("\"%s\"", table_nm);
    `uvm_info(this.get_full_name(), {table_nm}, UVM_LOW)
    smtdv_sqlite3::create_tb(table_nm);
    foreach (attr_longint[i])
      smtdv_sqlite3::register_longint_field(table_nm, attr_longint[i]);
    smtdv_sqlite3::exec_field(table_nm);
  endfunction

  // need be stream byte
  virtual function mem_store_byte_cb(gene_mem_addr_t addr, byte unsigned data, longint cyc);
    smtdv_sqlite3::insert_value(table_nm, "dec_addr",    $psprintf("%d", addr));
    smtdv_sqlite3::insert_value(table_nm, "dec_rw",      $psprintf("%d", WR));
    smtdv_sqlite3::insert_value(table_nm, {$psprintf("dec_data_%03d", 0)}, $psprintf("%d", data));
    smtdv_sqlite3::insert_value(table_nm, "dec_bg_cyc",  $psprintf("%d", cyc));
    smtdv_sqlite3::insert_value(table_nm, "dec_ed_cyc",  $psprintf("%d", cyc));
    smtdv_sqlite3::exec_value(table_nm);
    smtdv_sqlite3::flush_value(table_nm);
  endfunction

  virtual function mem_load_byte_cb(gene_mem_addr_t addr, byte unsigned  data, longint cyc);
    smtdv_sqlite3::insert_value(table_nm, "dec_addr",    $psprintf("%d", addr));
    smtdv_sqlite3::insert_value(table_nm, "dec_rw",      $psprintf("%d", RD));
    smtdv_sqlite3::insert_value(table_nm, {$psprintf("dec_data_%03d", 0)}, $psprintf("%d", data));
    smtdv_sqlite3::insert_value(table_nm, "dec_bg_cyc",  $psprintf("%d", cyc));
    smtdv_sqlite3::insert_value(table_nm, "dec_ed_cyc",  $psprintf("%d", cyc));
    smtdv_sqlite3::exec_value(table_nm);
    smtdv_sqlite3::flush_value(table_nm);
  endfunction

  // find first best match trx
  // find last best match trx
  //static function void find_last_best_match_trx(string table_nm, ref smtdv_sequence_item src, ref smtdv_sequence_item ret);
  //endfunction
  // find chunk best match trxs
  // find max continuous addr hit
  // find throughput
  // find best visited trace path
  //
endclass
