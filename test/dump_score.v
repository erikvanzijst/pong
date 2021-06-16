module dump();
    initial begin
        $dumpfile ("score.vcd");
        $dumpvars (0, score);
        #1;
    end
endmodule
