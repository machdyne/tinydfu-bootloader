/* DFU Board information definitions for the Lone Dynamics Konfekt */
localparam SPI_FLASH_SIZE = (2 * 1024 * 1024);
localparam SPI_ERASE_SIZE = 4096;
localparam SPI_PAGE_SIZE  = 256;

/* Flash partition layout */
localparam BOOTPART_SIZE = (1024 * 1024);
localparam USERPART_SIZE = (1024 * 1024);
localparam DATAPART_SIZE = (SPI_FLASH_SIZE - BOOTPART_SIZE - USERPART_SIZE);

localparam BOOTPART_START = 0;
localparam USERPART_START = BOOTPART_START + BOOTPART_SIZE;
localparam DATAPART_START = USERPART_START + USERPART_SIZE;

/* How many security registers are there? */
localparam SPI_SECURITY_REGISTERS = 3;
localparam SPI_SECURITY_REG_SHIFT = 12;

/* USB VID/PID Definitions */
localparam BOARD_VID = 'h16d0;  /* MCS */
localparam BOARD_PID = 'h116d;  /* Konfekt DFU Bootloader */

/* String Descriptors */
localparam BOARD_MFR_NAME = "Lone Dynamics Corporation";
localparam BOARD_PRODUCT_NAME = "Konfekt DFU Bootloader";
localparam BOARD_SERIAL = "000000";
