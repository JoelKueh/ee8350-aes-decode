// ksch_buffer_if.sv
//
// Interface for the key schedule buffer. Bound to the DUT and passed to the
// Key Schedule Buffer Agent for passive monitoring of the round key.
//
// Implements pin-level assertions including a LIFO ordering check and
// X-Propagation checks.
//

interface ksch_buffer_if#(
    parameter int KSCH_BUFFER_DEPTH
) (
    inout logic clk,
    inout logic rst
); 

    // Decrypt facing round key interfcae.
    logic [127:0] rkey_decrypt;
    logic         rkey_vld;
    logic         next_rkey_decrypt;

    // Expand facing round key interfcae.
    logic [127:0] rkey_keyexp;
    logic [127:0] rkey_vld_keyexp;

    // Modport definitions
    modport dut (
        output rkey_decrypt, rkey_vld_decrypt, next_rkey_decrypt, rkey_keyexp, rkey_vld_keyexp
    );

    modport tb (
        input  rkey_decrypt, rkey_vld_decrypt, next_rkey_decrypt, rkey_keyexp, rkey_vld_keyexp
    );

    // Clocking block definitions
    clocking tb_cb @(posedge clk);
        default input #1step output #1step;
        input  rkey_decrypt, rkey_vld_decrypt, next_rkey_decrypt, rkey_keyexp, rkey_vld_keyexp;
    endclocking

    // Reusable interface monitoring tasks
    task automatic rkey_keyexp_wait_handshake();
        forever begin
            @(tb_cb);
            if (tb_cb.rkey_vld_keyexp === 1)
                break;
        end
    endtask

    task automatic rkey_keyexp_get_key(inout logic [127:0] key);
        rkey_keyexp_wait_handshake();
        key = tb_cb.rkey_keyexp;
    endtask

    task automatic rkey_decode_wait_handshake();
        forever begin
            @(tb_cb);
            if (tb_cb.rkey_vld_decode === 1)
                break;
        end
    endtask

    task automatic rkey_decode_get_key(inout logic [127:0] key);
        rkey_decode_wait_handshake();
        key = tb_cb.rkey_decode;
    endtask

    // Asynchronous ksch buffer data predictor
    logic [127:0] expected_data[KSCH_BUFFER_DEPTH];
    integer expected_wr_ptr;
    integer expected_rd_ptr;
    always @(posedge clk) begin
        if (rst) begin
            expected_wr_ptr <= 0;
            expected_rd_ptr <= KSCH_BUFFER_DEPTH-1;
        end else begin
            // Write pointer advance
            if (rkey_vld_keyexp) begin
                expected_data[expected_wr_ptr] <= rkey_decrypt;
                expected_wr_ptr <= expected_wr_ptr + 1 == KSCH_BUFFER_DEPTH ? 0 :  expected_wr_ptr + 1;
            end

            // Read pointer advance
            if (rkey_vld_decode) begin
                expected_rd_ptr <= expected_rd_ptr == 0 ? KSCH_BUFFER_DEPTH - 1 : expected_rd_ptr - 1;
            end
        end
    end

    // Asynchronous ksch buffer order check
    property p_ksch_buffer_lifo;
        @(posedge clk) disable iff (rst)
        rkey_vld_decrypt |-> rkey_decrypt == expected_data[expected_rd_ptr];
    endproperty
    a_p_ksch_buffer_lifo: assert property (p_ksch_buffer_lifo)
    else $error("Data ordering missmatch!");
    c_p_ksch_buffer_lifo: cover property (p_ksch_buffer_lifo);

    // X-Propagation check for the decode side of the buffer
    property p_ksch_buffer_decrypt_x_prop;
        @(posedge clk) disable iff (rst)
        rkey_vld_decrypt |-> !$isunknown(rkey_decrypt);
    endproperty
    a_p_ksch_buffer_decrypt_x_prop: assert property (p_ksch_buffer_decrypt_x_prop)
    else $error("Invalid data on rkey_decrypt");
    c_p_ksch_buffer_decrypt_x_prop: cover property (p_ksch_buffer_decrypt_x_prop);

    // X-Propagation check for the expander side of the buffer
    property p_ksch_buffer_keyexp_x_prop;
        @(posedge clk) disable iff (rst)
        rkey_vld_keyexp |-> !$isunknown(rkey_keyexp);
    endproperty
    a_p_ksch_buffer_keyexp_x_prop: assert property (p_ksch_buffer_keyexp_x_prop)
    else $error("Invalid data on rkey_keyexp");
    c_p_ksch_buffer_keyexp_x_prop: cover property (p_ksch_buffer_keyexp_x_prop);

endinterface
