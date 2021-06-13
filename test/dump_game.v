module dump();
    initial begin
        $dumpfile ("game.vcd");
        $dumpvars (0, game);
        #1;
    end
endmodule
