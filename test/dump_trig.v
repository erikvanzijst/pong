module dump();
    initial begin
        $dumpfile ("trig.vcd");
        $dumpvars (0, trig);
        #1;
    end
endmodule
