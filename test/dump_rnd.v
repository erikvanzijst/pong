module dump();
    initial begin
        $dumpfile ("rnd.vcd");
        $dumpvars (0, rnd);
        #1;
    end
endmodule
