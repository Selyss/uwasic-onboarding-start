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
