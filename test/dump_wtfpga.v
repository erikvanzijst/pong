module dump();
    initial begin
        $dumpfile ("wtfpga.vcd");
        $dumpvars (0, top);
        #1;
    end
endmodule
