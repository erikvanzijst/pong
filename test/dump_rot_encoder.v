module dump();
    initial begin
        $dumpfile ("rot_encoder.vcd");
        $dumpvars (0, rot_encoder);
        #1;
    end
endmodule
