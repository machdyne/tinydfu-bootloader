/* DFU Board information definitions for the Lone Dynamics Kuchen */
localparam SPI_FLASH_SIZE = (1 * 1024 * 1024);
localparam SPI_ERASE_SIZE = 4096;
localparam SPI_PAGE_SIZE  = 256;

localparam BOOTPART_SIZE = (33 * 4096);
localparam USERPART_SIZE = (33 * 4096);
localparam DATAPART_SIZE = (SPI_FLASH_SIZE - BOOTPART_SIZE - USERPART_SIZE);

localparam BOOTPART_START = 0;
localparam USERPART_START = 163840;
localparam DATAPART_START = 327680;

/* How many security registers are there? */
localparam SPI_SECURITY_REGISTERS = 3;
localparam SPI_SECURITY_REG_SHIFT = 8;

/* USB VID/PID Definitions */
localparam BOARD_VID = 'h16D0;  /* MCS */
localparam BOARD_PID = 'h116D;  /* Kuchen DFU Bootloader */

/* String Descriptors */
localparam BOARD_MFR_NAME = "Lone Dynamics Corporation";
localparam BOARD_PRODUCT_NAME = "Kuchen DFU Bootloader";
localparam BOARD_SERIAL = "000000";
