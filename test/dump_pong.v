module dump();
    initial begin
        $dumpfile ("pong.vcd");
        $dumpvars (0, pong);
        #1;
    end
endmodule
