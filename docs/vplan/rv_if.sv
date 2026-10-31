// rv_if.sv
//
// Interface for a generic ready/valid interface. Bound to the DUT and passed
// to the Decrypter and Expander agents for monitoring and driving.
//
// Implements a pin-level X-Propagation check.
//

interface rv_if#(
    parameter int DATA_W
) (
    inout logic clk,
    inout logic rst
);

    // Signal declarations
    logic              valid;
    logic              ready;
    logic [DATA_W-1:0] data;

    // Modport definitions
    modport mstr (
        input  ready,
        output valid, data
    );

    modport slv (
        input  valid, data,
        output ready
    );

    // Clocking block definitions
    clocking mon_cb @(posedge clk);
        default input #1step;
        input valid, data, ready;
    endclocking

    clocking mstr_cb @(posedge clk);
        default input #1step output #1step;
        input ready;
        output valid, data;
    endclocking

    clocking slv_cb @(posedge clk);
        default input #1step output #1step;
        input valid, data;
        output ready;
    endclocking

    // Reusable interface monitoring/driving tasks
    task automatic wait_handshake();
        forever begin
            @(mon_cb);
            if (mon_cb.rkey_vld_decode === 1)
                break;
        end
    endtask

    task automatic get_data(inout logic [DATA_W-1:0] data_out);
        wait_handshake();
        data_out = data;
    endtask

    task automatic drive_data(input logic [DATA_W-1:0] data_in);
        mstr_cb.valid <= 1'b1;
        mstr_cb.data  <= data_in;
        wait_handshake();
        mstr_cb.valid <= 1'b0;
        mstr_cb.data  <= 'x;
    endtask

    task automatic drive_ready(input bit ready);
        slv_cb.ready <= ready;
        @(rd_slv_cb);
    endtask

    // Asynchronous ready/valid X-Propagation assertion.
    property p_rv_x_prop;
        @(posedge clk) disable iff (rst)
        valid |-> !$isunknown(data);
    endproperty
    a_p_rv_x_prop: assert property (p_rv_x_prop)
    else $error("Invalid data on ready/valid interface");
    c_p_rv_x_prop: cover property (p_rv_x_prop);

endinterface
