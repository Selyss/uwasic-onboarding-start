module spi_peripheral (
    input wire clk, // system clock (10 mhz)
    input wire rst_n, // async reset, active low

    // raw SPI signals
    input wire nCS, // raw SPI chip select
    input wire SCLK, // raw SPI clock
    input wire COPI, // raw SPI data in

    output reg [7:0] en_reg_out_7_0,
    output reg  [7:0]  en_reg_out_15_8,
    output reg  [7:0]  en_reg_pwm_7_0,
    output reg  [7:0]  en_reg_pwm_15_8,
    output reg  [7:0]  pwm_duty_cycle
);

reg nCS_ff1, nCS_ff2;
reg SCLK_ff1, SCLK_ff2;
reg COPI_ff1, COPI_ff2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0 <= 8'h00;
        en_reg_out_15_8 <= 8'h00;
        en_reg_pwm_7_0 <= 8'h00;
        en_reg_pwm_15_8 <= 8'h00;
        pwm_duty_cycle <= 8'h00;
    end else begin
        // update after full valid transaction for writes
        if (transaction_ready && rw_bit) begin
            case (addr)
                7'h00: en_reg_out_7_0 <= data;
                7'h01: en_reg_out_15_8  <= data;
                7'h02: en_reg_pwm_7_0   <= data;
                7'h03: en_reg_pwm_15_8  <= data;
                7'h04: pwm_duty_cycle   <= data;
                default: ; // ignore invalid addresses
            endcase
        end

    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nCS_ff1 <= 1; nCS_ff2 <= 1;
        SCLK_ff1 <= 0; SCLK_ff2 <= 0;
        COPI_ff1 <= 0; COPI_ff2 <= 0;
    end else begin
        nCS_ff1 <= nCS;
        nCS_ff2 <= nCS_ff1;

        SCLK_ff1 <= SCLK;
        SCLK_ff2 <= SCLK_ff1;

        COPI_ff1 <= COPI;
        COPI_ff2 <= COPI_ff1;
    end
end

wire sclk_rising = (SCLK_ff1 & ~SCLK_ff2);
wire ncs_falling = (~nCS_ff1 & nCS_ff2);
wire ncs_rising = (nCS_ff1 & ~nCS_ff2);

reg [15:0] shift_reg;
reg [4:0] bit_count; // 5 bits wide to hold values up to 16

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bit_count <= 0;
        shift_reg <= 16'd0;
    end else begin
        if (ncs_falling) begin
            // transaction starting
            bit_count <= 0;
            shift_reg <= 16'd0;
        end else if (!nCS_ff2 && sclk_rising) begin
            // transaction in progress
            shift_reg <= {shift_reg[14:0], COPI_ff2};
            bit_count <= bit_count + 1;
        end
    end
end

reg transaction_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        transaction_ready <= 0;
    end else begin
        if (ncs_rising && bit_count == 16) begin
            transaction_ready <= 1'b1;
        end else begin
            transaction_ready <= 1'b0; // clear when not needed
        end
    end
end

// helper signals
wire rw_bit;
wire [6:0] addr;
wire [7:0] data;

assign rw_bit = shift_reg[15];
assign addr = shift_reg[14:8];
assign data = shift_reg[7:0];

endmodule