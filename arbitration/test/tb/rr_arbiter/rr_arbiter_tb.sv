///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// Date Created: 02/12/2021
// Author: Heqing Huang
//
// ================== Description ==================
//
// A testbench for rr_arbiter
//
///////////////////////////////////////////////////////////////////////////////

interface rr_arbiter_if #(parameter WIDTH=8);
    logic                   clk;
    logic                   rst;
    logic [WIDTH-1:0]       req;
    logic [WIDTH-1:0]       grant;
endinterface

class xaction #(parameter WIDTH=8);
    rand bit [WIDTH-1:0] req;
    bit [WIDTH-1:0] grant;
endclass

class Generator #(parameter WIDTH=8, parameter NUM=20);
    xaction #(WIDTH) t;
    mailbox mbx;
    event drv_done;
    event gen_done;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        for (int i = 0; i < NUM; i++) begin
            t.randomize();
            mbx.put(t);
            //$display("[Generator]: Generated new request: %b at %0t", t.req, $time);
            @(drv_done);
        end
        ->gen_done;
    endtask

endclass

class Driver #(parameter WIDTH=8);
    xaction #(WIDTH) t;
    mailbox mbx;
    event drv_done;
    event gen_done;
    event drv_finish;
    virtual rr_arbiter_if #(WIDTH) vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        fork
            forever begin
                mbx.get(t);
                @(posedge vif.clk);
                vif.req <= t.req; // using <= to aviod race condition
                //$display("[Driver]: Sending request to DUT: %b at %0t", t.req, $time);
                ->drv_done;
            end
            begin
                @(gen_done);
                @(posedge vif.clk);
                vif.req <= 0;
            end
        join_any
        -> drv_finish;
    endtask
endclass

class Monitor #(parameter WIDTH=8);
    xaction #(WIDTH) t;
    mailbox mbx;
    virtual rr_arbiter_if #(WIDTH) vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        forever begin
            // req and grant are in the same clock
            @(negedge vif.clk);
            t.req <= vif.req;
            t.grant <= vif.grant;
            mbx.put(t);
            //$display("[Monitor]: Data send to Scoreboard: req - %b, grant - %b at %0t", t.req, t.grant, $time);
        end
    endtask

endclass

class Scoreboard #(parameter WIDTH=8);
    xaction #(WIDTH) t;
    mailbox mbx;
    bit [WIDTH-1:0] remaining_req = 0;
    bit [WIDTH-1:0] masked_req = 0;
    bit [WIDTH-1:0] grant;
    integer error = 0;
    integer id = 0;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        forever begin
            mbx.get(t);
            if (t.req != 0) begin
                id++;
                $display("[Scoreboard]: [#%0d] Data received: req - <%b>, grant - <%b> at %0t", id, t.req, t.grant, $time);
                masked_req = remaining_req & t.req;
                if (masked_req == 0) begin // new round
                    grant = t.req & (~t.req + 1);
                    assert(grant == t.grant) else begin
                        $error("[Scoreboard]: 1 ERROR: Wrong grant. Expect: <%b>", grant);
                        error++;
                    end
                    remaining_req = t.req & ~grant;
                end
                else begin // not new round
                    grant = masked_req & (~masked_req + 1);
                    assert(grant == t.grant) else begin
                        $error("[Scoreboard]: 2 ERROR: Wrong grant. Expect: %b", grant);
                        //$display("[Scoreboard]: remaining_req: %b", remaining_req);
                        error++;
                    end
                    remaining_req = remaining_req & ~grant;
                end

            end
            else begin
                remaining_req = 0;
            end
        end
    endtask

endclass

class Environment #(parameter WIDTH=8, parameter NUM=20);
    Generator #(WIDTH, NUM) gen;
    Driver #(WIDTH) drv;
    Monitor #(WIDTH) mon;
    Scoreboard #(WIDTH) scb;

    mailbox mbx_gen2drv;
    mailbox mbx_mon2scb;

    virtual rr_arbiter_if #(WIDTH) vif;

    event drv_done;
    event gen_done;
    event drv_finish;

    function new(mailbox mbx_gen2drv, mailbox mbx_mon2scb);
        this.mbx_gen2drv = mbx_gen2drv;
        this.mbx_mon2scb = mbx_mon2scb;

        gen = new(mbx_gen2drv);
        drv = new(mbx_gen2drv);
        mon = new(mbx_mon2scb);
        scb = new(mbx_mon2scb);
    endfunction

    task run();
        drv.vif = vif;
        mon.vif = vif;
        gen.drv_done = drv_done;
        gen.gen_done = gen_done;
        drv.drv_done = drv_done;
        drv.gen_done = gen_done;
        drv.drv_finish = drv_finish;
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask

endclass

module rr_arbiter_tb;

    localparam  WIDTH = 4;
    rr_arbiter_if #(WIDTH) dut_if();

    mailbox mbx_gen2drv;
    mailbox mbx_mon2scb;
    Environment #(WIDTH, 100) env;

    rr_arbiter #(.WIDTH(WIDTH))
    rr_arbiter_dut (
        .clk (dut_if.clk),
        .rst (dut_if.rst),
        .req (dut_if.req),
        .grant (dut_if.grant));

    always #5 dut_if.clk = ~dut_if.clk;

    initial begin
        dut_if.clk = 0;
        dut_if.rst = 0;
        dut_if.req = 0;
    end

    initial begin
        mbx_gen2drv = new();
        mbx_mon2scb = new();
        env = new(mbx_gen2drv, mbx_mon2scb);
    end

    initial
    begin
        dut_if.rst = 1'b1;
        #20;
        dut_if.rst = 1'b0;
        @(posedge dut_if.clk);

        env.vif = dut_if;
        env.run();
        @(env.drv_finish);
        #100;
        @(posedge dut_if.clk);
        if (env.scb.error == 0)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED");
        $finish;
    end


    initial begin
        $dumpfile("rr_arbiter_test.vcd");
        $dumpvars(0,rr_arbiter_tb);
    end

endmodule
