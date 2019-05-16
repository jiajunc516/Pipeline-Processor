module mux2
    #(parameter WD = 32
    )
    (
        input logic [WD-1:0] a,
        input logic [WD-1:0] b,
        input logic s,
        output logic [WD-1:0] y
    );
    assign y = s ? b : a;
endmodule:mux2