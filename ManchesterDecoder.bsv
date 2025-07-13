import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            if (in matches Invalid) begin
                prev <= Invalid;
                outFifo.enq(Invalid);
                i <= 0;
            end
            else if (in matches Valid .x) begin
                let adjusted_i = i;
                if (prev matches Valid .p &&& p != x) begin
                    // Adjust phase based on current i
                    if (i == 7) begin
                        adjusted_i = 0; // Early transition, skip to next cycle
                    end
                    else if (i == 1) begin
                        adjusted_i = 0; // Late transition, retard phase
                    end
                    else if (i == 2) begin
                        adjusted_i = 0; // Very late, reset to start
                    end
                    // Decode only if transition is at mid-symbol (i == 4)
                    if (adjusted_i == 4) begin
                        if (p == 0 &&& x == 1) begin
                            outFifo.enq(Valid(1));
                        end
                        else if (p == 1 &&& x == 0) begin
                            outFifo.enq(Valid(0));
                        end
                    end
                end
                prev <= Valid(x);
                i <= (adjusted_i == 7) ? 0 : adjusted_i + 1;
            end
        endmethod
    endinterface
    interface out = toGet(outFifo);
endmodule