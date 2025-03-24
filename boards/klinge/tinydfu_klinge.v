/*
 *  TinyDFU Bootloader for the Lone Dynamics Klinge computer.
 *  (based on the Logicbone ECP5 bootloader)
 */

module tinydfu_klinge (
    input        refclk,
    output       resetn,

    inout        usb_ufp_dp,
    inout        usb_ufp_dm,
    output       usb_ufp_pull,

    output			led,

    output       flash_csel,
    output       flash_mosi,
    input        flash_miso,

);

wire clk_48mhz = refclk;
wire clk_locked;
reg  clk_24mhz = 0;
reg  clk = 0;
always @(posedge clk_48mhz) clk_24mhz <= ~clk_24mhz;
always @(posedge clk_24mhz) clk <= ~clk;

// The SPI serial clock requires a special IP block to access.
wire flash_sclk;
USRMCLK usr_sclk(.USRMCLKI(flash_sclk), .USRMCLKTS(1'b0));

//////////////////////////
// LED Patterns
//////////////////////////
reg [31:0] led_counter;
always @(posedge clk) begin
    led_counter <= led_counter + 1;
end

// Simple blink pattern when idle.
wire [3:0] led_idle = {3'b0, led_counter[21]};

// Cylon pattern when programming.
reg [2:0] led_cylon_count = 0;
reg [3:0] led_cylon = 4'b0;
always @(posedge led_counter[20]) begin
   if (led_cylon_count) led_cylon_count <= led_cylon_count - 1;
   else led_cylon_count <= 5;

   if (led_cylon_count == 4) led_cylon <= 4'b0100;
   else if (led_cylon_count == 5) led_cylon <= 4'b0010;
   else led_cylon <= 4'b0001 << led_cylon_count[1:0];
end

// Select the LED pattern by DFU state.
wire dfu_detach;
wire [7:0] dfu_state;
assign led = (dfu_state == 'h02) ? ~led_idle : ~led_cylon;

//////////////////////////
// Reset and Multiboot
//////////////////////////

reg user_boot_now = 1'b0;
reg user_auto_boot = 1'b1;

reg [15:0] reset_delay = 16'hffff;
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

BB pin_resetn( .I( 1'b0 ), .T( ~user_boot_now ), .O( ), .B( resetn ) );

wire usb_p_tx;
wire usb_n_tx;
wire usb_p_rx;
wire usb_n_rx;
wire usb_tx_en;

// USB DFU - this instanciates the entire USB device.
usb_dfu_core dfu (
  .clk_48mhz  (clk_48mhz),
  .clk        (clk),
  .reset      (reset_delay),

  // USB signals
  .usb_p_tx( usb_p_tx ),
  .usb_n_tx( usb_n_tx ),
  .usb_p_rx( usb_p_rx ),
  .usb_n_rx( usb_n_rx ),
  .usb_tx_en( usb_tx_en ),

  // SPI
  .spi_csel( flash_csel ),
  .spi_clk( flash_sclk ),
  .spi_mosi( flash_mosi ),
  .spi_miso( flash_miso ),

  // DFU State and debug
  .dfu_detach( dfu_detach ),
  .dfu_state( dfu_state ),
  //.debug( )
);

// USB Physical interface
usb_phy_ecp5 phy (
  .pin_usb_p (usb_ufp_dp),
  .pin_usb_n (usb_ufp_dm),

  .usb_p_tx( usb_p_tx ),
  .usb_n_tx( usb_n_tx ),
  .usb_p_rx( usb_p_rx ),
  .usb_n_rx( usb_n_rx ),
  .usb_tx_en( usb_tx_en ),
);

// USB Host Detect Pull Up
BB pin_usb_pull( .I( 1'b1 ), .T( reset_delay ), .O( ), .B( usb_ufp_pull ) );

endmodule
