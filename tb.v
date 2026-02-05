`timescale 1ns / 1ps

module tb;

    reg  [11:0] ogtc;
    wire [11:0] abstc;
    wire sign_bit;
    wire [2:0] nexp;
    wire [3:0] nfigs;

    wire [2:0] exp;
    wire [3:0] figs;
    wire [3:0] ind;
    
    FPCVT complete(
        .d(ogtc),
        .s(sign_bit),
        .e(nexp),
        .f(nfigs)
    );
//     Instantiate the DUT
    absolute_value dut (
        .ogtc(ogtc),
        .abstc(abstc),
        .sign_bit(sign_bit)
    );
    
    extract_bits dut2 (
        .abstc(abstc),
        .exp(exp),
        .figs(figs),
        .i(ind)
    );
    
    rounding dut3 (
        .abstc(abstc),
        .i(ind),
        .exp(exp),
        .figs(figs),
        .nexp(nexp),
        .nfigs(nfigs)
    );
    
    integer i;
    
    // Apply test vectors
    initial begin

//        ogtc = 12'b000000000110; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
       
//        ogtc = 12'b000110100110; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
        
//        ogtc = 12'b000000101110; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
        
//        ogtc = 12'b000000101111; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
        
//        ogtc = 12'b000001111100; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
        
//        ogtc = 12'b011111111111; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
        
//        ogtc = 12'b100000000110; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);                        
//        ogtc = 12'b111111111111; #10;
//        $display("time=%0t test=%b out=%b sign_bit=%b exp=%b figs=%b nexp=%b nfigs=%b", $time, ogtc, abstc, sign_bit, exp, figs, nexp, nfigs);
//        $display("result: %b", result);
            for (i = -2048; i <= 2047; i = i + 1) begin
                ogtc = i;
                #10;
                $display("OG: %b || %b | %b | %b", ogtc, sign_bit, nexp, nfigs);
            end
        $finish;
    end
   
endmodule
