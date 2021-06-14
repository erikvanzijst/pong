module dump();
    initial begin
        $dumpfile ("gatelevel.vcd");
        $dumpvars (0, pong);
        #1;
    end
endmodule
