import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;
    
    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            Bit#(3) next_i;

             if (in == Invalid) begin
                outFifo.enq(Invalid);
                i <= 0;
                prev <= Invalid;
            end else begin
                if (in == Valid(1) && prev == Valid(0) && i>=2 && i<=5) begin
                    outFifo.enq(Valid(1)); 
                    i <= 4;
                end else if (in == Valid(0) && prev == Valid(1)&& i>=2 && i<=5) begin
                    outFifo.enq(Valid(0)); 
                    i <= 4;
                end else if (in == Valid(1) && prev == Valid(0)&& i<=1 ) begin 
                    i <= 0;
                end else begin
                    i <= (i == 7) ? 0 : i + 1;
                end

                prev <= in;
            end
        endmethod
    endinterface

    interface out = toGet(outFifo); 
endmodule