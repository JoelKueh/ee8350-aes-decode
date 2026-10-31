// aes_core_adapter.sv
//
// Adapter for the AES core. Bridges the interfaces used by the agents to the
// wire definitions used by teh DUT.
//

module aes_core_wrapper#(
    parameter int KEYLEN
) (
    input wire clk,
    input wire rst,
    rv_if.slv m_kt,
    rv_if.slv m_ct,
    rv_if.mstr m_pt,
    ksch_buffer_if.dut m_ksch_buffer
);

    // Glue wire instantiation
    wire [0:127] kt;
    wire         kt_vld;
    wire         kt_rdy;
    
    wire [0:127] ct;
    wire         ct_vld;
    wire         ct_rdy;
    
    wire [0:127] pt;
    wire         pt_vld;

    // Interface assignment
    assign kt     = kt.data;
    assign kt_vld = kt.valid;
    assign kt.ready = kt_rdy;

    assign ct     = ct.data;
    assign ct_vld = ct.valid;
    assign ct.ready = ct_rdy;

    assign pt     = pt.data;
    assign pt_vld = pt.valid;

    // Parameterizable DUT instantiation
    generate
        if (KEYLEN == 128) begin
            aes_decrypt128 dut (.*);
        end else if (KEYLEN == 192) begin
            aes_decrypt192 dut (.*);
        end else if (KEYLEN == 256) begin
            aes_decrypt256 dut (.*);
        end else begin
            initial begin
                `uvm_fatal("CONFIGURATION", $sformat("Invalid keylength: KEYLEN=%d", KEYLEN))
            end
        end
    endgenerate

endmodule
