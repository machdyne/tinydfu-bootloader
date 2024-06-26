/*
 *  TinyDFU Bootloader for the Lone Dynamics Riegel.
 *  (based on the TinyFPGA BX bootloader)
 */

module tinydfu_riegel (
        input  pin_clk,

        inout  pin_usb_p,
        inout  pin_usb_n,
        output pin_pu,

        output pin_led,

        output pin_16_cs,
        output pin_15_sck,
        output pin_14_mosi,
        input pin_17_miso,

        output [3:0] debug
    );

    wire clk_48mhz = pin_clk;
    wire clk = clkdiv[1];
    reg [1:0] clkdiv = 0;

    always @(posedge clk_48mhz) clkdiv <= clkdiv + 1;

    //////////////////////////
    // LED Patterns
    //////////////////////////
    reg [31:0] led_counter = 0;
    always @(posedge clk) begin
        led_counter <= led_counter + 1;
    end

    // Double blink when idle.
    wire [2:0] led_blinkstate  = led_counter[22:20];
    wire led_idle = (led_blinkstate == 3) || (led_blinkstate == 5);

    // Fadepulse during programming.
    wire [4:0] led_pwmval = led_counter[23] ? led_counter[22:18] : (5'b11111 - led_counter[22:18]);
    wire led_busy = (led_counter[17:13] >= led_pwmval);

    // Select the LED pattern by DFU state.
    wire [7:0] dfu_state;
    assign pin_led = (dfu_state == 'h00) ? ~led_idle : (dfu_state == 'h02) ? led_idle : led_busy;

    //////////////////////////
    // Reset and Multiboot
    //////////////////////////

    reg user_boot_now = 1'b0;
    reg user_auto_boot = 1'b1;

    reg [15:0] reset_delay = 12000;
    reg [31:0] boot_delay = (12000000 * 5);
    wire dfu_detach;
    always @(posedge clk) begin

        if (reset_delay) reset_delay <= reset_delay - 1;
        if (boot_delay) boot_delay <= boot_delay - 1;

        // if the user does something with dfu, cancel auto boot
        if (dfu_state > 2) user_auto_boot = 1'b0;

        // if the user detaches, boot now
        if (dfu_detach) user_boot_now = 1'b1;

        // if autoboot is enabled and the timer ends, boot now
        if (user_auto_boot && boot_delay == 0) user_boot_now = 1'b1;

    end
  
    SB_WARMBOOT warmboot_inst (
        .S1(1'b0),
        .S0(1'b1),
        .BOOT(user_boot_now)
    );

    //////////////////////////
    // USB DFU Device
    //////////////////////////
    wire usb_p_tx;
    wire usb_n_tx;
    wire usb_p_rx;
    wire usb_n_rx;
    wire usb_tx_en;

    // USB DFU - this instanciates the entire USB device.
    usb_dfu_core dfu (
        .clk_48mhz  (clk_48mhz),
        .clk        (clk),
        .reset      (reset_delay != 0),

        // USB signals
        .usb_p_tx( usb_p_tx ),
        .usb_n_tx( usb_n_tx ),
        .usb_p_rx( usb_p_rx ),
        .usb_n_rx( usb_n_rx ),
        .usb_tx_en( usb_tx_en ),

        // SPI
        .spi_csel( pin_16_cs ),
        .spi_clk( pin_15_sck ),
        .spi_mosi( pin_14_mosi ),
        .spi_miso( pin_17_miso ),  

        .dfu_detach( dfu_detach ),
        .dfu_state( dfu_state ),
        .debug( debug )
    );

    // USB Physical interface
    usb_phy_ice40 phy (
        .pin_usb_p (pin_usb_p),
        .pin_usb_n (pin_usb_n),

        .usb_p_tx( usb_p_tx ),
        .usb_n_tx( usb_n_tx ),
        .usb_p_rx( usb_p_rx ),
        .usb_n_rx( usb_n_rx ),
        .usb_tx_en( usb_tx_en ),
    );

    // USB Host Detect Pull Up
    assign pin_pu = 1'b1;

endmodule
