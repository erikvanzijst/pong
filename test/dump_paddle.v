module dump();
    initial begin
        $dumpfile ("paddle.vcd");
        $dumpvars (0, paddle);
        #1;
    end
endmodule
