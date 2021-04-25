module dump();
    initial begin
        $dumpfile ("math.vcd");
        $dumpvars (0, sin);
        #1;
    end
endmodule
