
module spi_peripheral(
   input wire COPI, 
   input wire nCS, 
   input wire SCLK, 
   input wire rst_n,
   input wire clk, 

   output reg[7:0] en_reg_out_7_0, //0x00
   output reg[7:0] en_reg_out_15_8, //0x01
   output reg[7:0] en_reg_pwm_7_0, //0x02
   output reg[7:0] en_reg_pwm_15_8, //0x03
   output reg[7:0] pwm_duty_cycle  //0x04
);

//SIGNAL SSYNCHRONIZATION

reg nCS_sync, nCS_sync2;
reg SCLK_sync, SCLK_sync2;
reg COPI_sync, COPI_sync2;

//sync 2 flipflops
always @(posedge clk)begin
    SCLK_sync <= SCLK;
    SCLK_sync2 <= SCLK_sync;

    COPI_sync <= COPI;
    COPI_sync2 <= COPI_sync;

    nCS_sync <= nCS;
    nCS_sync2 <= nCS_sync;
end

//EDGE DETECTION

reg sclk_prev; //previous SCLK
wire sclk_curr = SCLK_sync2; //current SCLK

reg ncs_prev; //previous nCS
wire ncs_curr = nCS_sync2; //current nCS

always @(posedge clk)begin
    sclk_prev <= sclk_curr;
    ncs_prev <= ncs_curr;
end

wire sclk_rise = (sclk_prev==1'b0) && (sclk_curr==1'b1); //sclk posedge
wire ncs_rise = (ncs_prev==1'b0) && (ncs_curr==1'b1); //ncs posedge

//BIT COUNTING
reg[4:0] bit_count; //bit counter
reg[15:0] shift_reg; 

reg transaction_accept;
localparam max_address = 7'h04;

always @(posedge clk or negedge rst_n) begin

    transaction_accept <= 1'b0;

    //reset
    if(!rst_n)begin
        //reset registers
        en_reg_out_7_0   <= 8'h00;
        en_reg_out_15_8  <= 8'h00;
        en_reg_pwm_7_0   <= 8'h00;
        en_reg_pwm_15_8  <= 8'h00;
        pwm_duty_cycle   <= 8'h00;

        //reset counter
        bit_count <= 1'd0;
        shift_reg <= 16'd0;

    end

    //when transaction active and SCLK rising edge and less than 16 bits shift bits
    else if (ncs_curr == 1'b0 && sclk_rise && bit_count<5'd16) begin
        shift_reg <= {shift_reg[14:0], COPI_sync2};
        bit_count <= bit_count +1;
    end

    //ADDRESS VALIDATION + TRANSCTION FINALIZATION
    if (ncs_rise) begin
        if (bit_count == 5'd16) begin

            // if write mode and valid address
            if (shift_reg[15] == 1'b1 && shift_reg[14:8] <= max_address) begin
            case (shift_reg[14:8])
                7'h00: en_reg_out_7_0    <= shift_reg[7:0];
                7'h01: en_reg_out_15_8   <= shift_reg[7:0];
                7'h02: en_reg_pwm_7_0    <= shift_reg[7:0];
                7'h03: en_reg_pwm_15_8   <= shift_reg[7:0];
                7'h04: pwm_duty_cycle    <= shift_reg[7:0];
                default: ; 
            endcase
        end
    end

    // reset capture for next transaction
    bit_count <= 0;
    shift_reg <= 0;
    end

end
endmodule

