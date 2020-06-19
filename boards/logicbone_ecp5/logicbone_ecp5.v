/*
    TinyDFU Bootloader

    Wrapping usb/usb_dfu_ice40.v.
*/

module logicbone_ecp5 (
        input  refclk,

        inout  usb_ufp_dp,
        inout  usb_ufp_dm,
        output usb_ufp_pull,

        output [3:0] led,

        output flash_csel,
        //output flash_sclk,
        output flash_mosi,
        input flash_miso,

        output [3:0] debug
    );

    wire clk_48mhz;

    wire clk_locked;

    // Use an icepll generated pll
    pll pll48( .clkin(refclk), .clkout0(clk_48mhz), .locked( clk_locked ) );

    // The SPI serial clock requires a special IP block to access.
    wire flash_sclk;
    USRMCLK usr_sclk(.USRMCLKI(flash_sclk), .USRMCLKTS(1'b0));

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    ////////
    //////// interface with iCE40 RGB LED driver
    ////////
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    wire [7:0] led_debug;

    // LED
    reg [22:0] led_counter;
    always @(posedge clk_48mhz) begin
        led_counter <= led_counter + 1;
    end
    assign led[0] = led_counter[22];


    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        if ( clk_locked )
            reset_cnt <= reset_cnt + reset;

    wire usb_p_tx;
    wire usb_n_tx;
    wire usb_p_rx;
    wire usb_n_rx;
    wire usb_tx_en;

    // usb DFU - this instanciates the entire USB device.
    usb_dfu dfu (
        .clk_48mhz  (clk_48mhz),
        .reset      (reset),

        // pins
        .pin_usb_p( usb_ufp_dp ),
        .pin_usb_n( usb_ufp_dm ),

        // SPI
        .spi_csel( flash_csel ),
        .spi_clk( flash_sclk ),
        .spi_mosi( flash_mosi ),
        .spi_miso( flash_miso ),  

        .debug( debug )
    );

    // USB Host Detect Pull Up
    assign usb_ufp_pull = 1'b1;

endmodule