module adder
    #(parameter WD = 8
    )
    (
        input logic [WD-1:0] a,
        input logic [WD-1:0] b,
        output logic [WD-1:0] y
    );
    assign y = a + b;
endmodule:adder