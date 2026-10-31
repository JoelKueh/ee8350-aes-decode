// aes_tb.sv
//
// Top-level testbench for the AES decryption core. Instantiates the DUT,
// binds the various interfaces, places virtual interfaces in the config db,
// and runs the test.
//

module aes_tb ();

    // Overridable key length parameter
    `ifdef P_KEYLEN
        parameter int KEYLEN = `P_KEYLEN;
    `else
        parameter int KEYLEN = 128;
    `endif

    parameter int KSCH_BUFFER_DEPTH =
        (KEYLEN == 128) ? 10 :
        (KEYLEN == 192) ? 12 :
        (KEYLEN == 256) ? 14 : 0;

    // Clock and Reset Instantiation
    wire clk;
    wire rst;

    // Interface Instantiation
    rv_if#(KEYLEN) m_kt;
    rv_if#(128) m_ct;
    rv_if#(128) m_pt;
    ksch_buffer_if#(KSCH_BUFFER_DEPTh) m_ksch_buffer;

    // Parameterizable DUT instantiation
    aes_core_wrapper#(KEYLEN) dut_wrapper (.*);

    // TODO: Run the test and configure the environment through the config db.

endmodule
