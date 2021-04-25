module dump();
    initial begin
        $dumpfile ("pong.vcd");
        $dumpvars (0, top);
        #1;
    end
endmodule
