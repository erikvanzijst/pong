module dump();
    initial begin
        $dumpfile ("ball.vcd");
        $dumpvars (0, ball);
        #1;
    end
endmodule
