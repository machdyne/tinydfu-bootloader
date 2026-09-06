/* DFU Board information definitions for the Lone Dynamics Obst */
localparam SPI_FLASH_SIZE = (2 * 1024 * 1024);
localparam SPI_ERASE_SIZE = 4096;
localparam SPI_PAGE_SIZE  = 256;

/* Flash partition layout */
/* 256K is about twice the compressed bootloader (Obst is ~123KB), and
   leaves the user partition big enough for a system that carries its
   own kernel and applications rather than only a bitstream.

   KEEP USERPART_START AND BOOTADDR IN THIS BOARD'S Makefile IN SYNC.
   They are the same number twice: this one tells dfu-util where to
   write, and BOOTADDR is baked into the bitstream by ecppack as the
   ECP5 multiboot jump target. Change one without the other and the
   board accepts a write, then jumps somewhere else and does not
   boot. */
localparam BOOTPART_SIZE = (256 * 1024);
localparam USERPART_SIZE = (1792 * 1024);
localparam DATAPART_SIZE = (SPI_FLASH_SIZE - BOOTPART_SIZE - USERPART_SIZE);

localparam BOOTPART_START = 0;
localparam USERPART_START = BOOTPART_START + BOOTPART_SIZE;
localparam DATAPART_START = USERPART_START + USERPART_SIZE;

/* Partition names, as shown by `dfu-util -l`.

   The sizes are in the names so that listing the device says which
   layout it has -- that is the whole check somebody upgrading needs,
   and the original bootloader shows no size at all, so its absence is
   itself the answer.

   `define, not localparam: usb/usb_dfu_ctrl_ep.v guards its own
   defaults with `ifndef, which tests the preprocessor and cannot see
   a localparam. A board that defines none of these gets the original
   names. */
`define BOOTPART_NAME "Boot Image (256KB)"
`define USERPART_NAME "User Image (1792KB)"

/* DATAPART is zero bytes on this board -- SPI_FLASH_SIZE minus the
   two partitions above -- and enumerating it unnamed invites somebody
   to write to alt=1 and wonder why nothing happened.

   THE SPACE IN "0 KB" IS LOAD-BEARING. A USB string descriptor is
   2*chars+2 bytes, and a control IN transfer ends when the device
   sends a packet SHORTER than MAX_IN_PACKET_SIZE, which is 32 in
   usb_dfu_ctrl_ep.v. "User Data (0KB)" is 15 characters, so its
   descriptor is exactly 32 bytes -- one full packet and no short one
   to end the transfer. The host waits for a terminating packet that
   never comes and dfu-util reports

     Failed to retrieve string descriptor 5
     ... alt=1, name="UNKNOWN"

   16 characters gives 34 bytes and terminates normally. Any name of
   15, 31 or 47 characters will hit this, on any board.

   The real fix belongs in usb_dfu_ctrl_ep.v, which should send a
   zero-length packet when the transfer is an exact multiple of
   MAX_IN_PACKET_SIZE. Until it does, keep an eye on the length of
   anything you put here. */
`define DATAPART_NAME "User Data (0 KB)"

/* How many security registers are there? */
localparam SPI_SECURITY_REGISTERS = 3;
localparam SPI_SECURITY_REG_SHIFT = 12;

/* USB VID/PID Definitions */
localparam BOARD_VID = 'h16d0;  /* MCS */
localparam BOARD_PID = 'h116d;  /* Obst DFU Bootloader */

/* String Descriptors */
localparam BOARD_MFR_NAME = "Lone Dynamics Corporation";
localparam BOARD_PRODUCT_NAME = "Obst DFU Bootloader";
localparam BOARD_SERIAL = "000000";
