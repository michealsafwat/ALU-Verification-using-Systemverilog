module ALU (
    input wire alu_clk,
    input wire rst_n,
    input wire alu_enable_a,
    input wire alu_enable_b,
    input wire alu_irq_clr,
    input wire alu_enable,
    input wire [1:0] alu_op_a,
    input wire [1:0] alu_op_b,
    input wire [7:0] alu_in_a,
    input wire [7:0] alu_in_b,
    output reg [7:0] alu_out,
    output reg alu_irq

);

  reg [7:0] out;
  reg irq;
  always @(posedge alu_clk or negedge rst_n) begin
    if (!rst_n) begin
      alu_out <= 8'b0;
      out <= 8'b0;
      alu_irq <= 1'b0;
      irq <= 1'b0;
    end else if (alu_enable && alu_enable_a) begin
      case (alu_op_a)
        2'b00: alu_out <= alu_in_a & alu_in_b;
        2'b01: alu_out <= ~(alu_in_a & alu_in_b);
        2'b10: alu_out <= alu_in_a | alu_in_b;
        2'b11: alu_out <= alu_in_a ^ alu_in_b;
      endcase
      
      if (!alu_irq_clr) begin
        case ({
          alu_op_a, alu_out
        })
          10'h0FF: alu_irq <= 1'b1;
          10'h100: alu_irq <= 1'b1;
          10'h2F8: alu_irq <= 1'b1;
          10'h383: alu_irq <= 1'b1;
          default: begin
            irq <= 1'b0;
          end
        endcase

      end else if (alu_irq_clr) begin
        case ({
          alu_op_a, alu_out
        })
          10'h0FF: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h100: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h2F8: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h383: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          default: begin
            alu_irq <= 1'b0;
            irq <= 1'b0;
          end
        endcase

      end

    end else if (alu_enable && alu_enable_b) begin
      case (alu_op_b)
        2'b00: alu_out <= ~(alu_in_a ^ alu_in_b);
        2'b01: alu_out <= alu_in_a & alu_in_b;
        2'b10: alu_out <= ~(alu_in_a | alu_in_b);
        2'b11: alu_out <= alu_in_a | alu_in_b;
      endcase
   
      if (!alu_irq_clr) begin
        case ({
          alu_op_b, alu_out
        })
          10'h0F1: alu_irq <= 1'b1;
          10'h1F4: alu_irq <= 1'b1;
          10'h2F5: alu_irq <= 1'b1;
          10'h3FF: alu_irq <= 1'b1;
          default: begin
            irq <= 1'b0;
          end
        endcase
      end else if (alu_irq_clr) begin
        case ({
          alu_op_b, alu_out
        })
          10'h0F1: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h1F4: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h2F5: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          10'h3FF: begin
            alu_irq <= ~irq;
            irq <= ~irq;
          end
          default: begin
            alu_irq <= 1'b0;
            irq <= 1'b0;
          end
        endcase

      end
    end

  end

endmodule
