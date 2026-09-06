##
## Make and program Obst
##

BASENAME = tinydfu
TARGETNAME = $(BASENAME)_obst
PROJTOP = tinydfu_obst

RTL_USB_DIR = ../../usb

SOURCES = \
	$(RTL_USB_DIR)/edge_detect.v \
	$(RTL_USB_DIR)/strobe.v \
	$(RTL_USB_DIR)/usb_fs_in_arb.v \
	$(RTL_USB_DIR)/usb_fs_in_pe.v \
	$(RTL_USB_DIR)/usb_fs_out_arb.v \
	$(RTL_USB_DIR)/usb_fs_out_pe.v \
	$(RTL_USB_DIR)/usb_fs_pe.v \
	$(RTL_USB_DIR)/usb_fs_rx.v \
	$(RTL_USB_DIR)/usb_fs_tx_mux.v \
	$(RTL_USB_DIR)/usb_fs_tx.v \
	$(RTL_USB_DIR)/usb_string_rom.v \
	$(RTL_USB_DIR)/usb_dfu_ctrl_ep.v \
	$(RTL_USB_DIR)/usb_spiflash_bridge.v \
	$(RTL_USB_DIR)/usb_dfu_core.v \
	$(RTL_USB_DIR)/usb_phy_ecp5.v

SRC = $(PROJTOP).v $(SOURCES)

PIN_DEF = obst_v0.lpf

DEVICE = --12k
PACKAGE = CABGA256
# KEEP IN SYNC WITH USERPART_START IN boardinfo.vh. ecppack bakes this
# into the bitstream as the ECP5 multiboot jump target; boardinfo.vh
# tells dfu-util where to write. They are the same number, and a
# mismatch produces a board that accepts a write and then does not
# boot, with nothing to say why.
BOOTADDR = 0x040000 # User image starts at 256KB

all: $(PROJTOP).bit $(PROJTOP).hex $(PROJTOP).svf
bootloader: $(PROJTOP).bit

synth: $(PROJTOP).json

$(PROJTOP).json: $(SRC)
	yosys -q -p 'synth_ecp5 -top $(PROJTOP) -json $@' $^

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ $(DEVICE) --package $(PACKAGE) --lpf $(PIN_DEF)

%.svf: %_out.config
	ecppack --svf $@ $<

%.bit: %_out.config
	ecppack --compress --bootaddr $(BOOTADDR) $< $@

%.hex: %.bit
	hexdump $^ > $@

prog: $(PROJTOP).svf
	openFPGALoader -c usb-blaster tinydfu_obst.bit	

prog_flash: $(PROJTOP).svf
	openFPGALoader -c usb-blaster -f tinydfu_obst.bit	

dfu: $(PROJTOP).bit
	dfu-util -d 16d0:116d -a2 -D $<

clean:
	rm -f $(PROJTOP).json $(PROJTOP).svf $(PROJTOP).bit $(PROJTOP)_out.config $(PROJTOP).hex

.SECONDARY:
.PHONY: all bitstream synth prog dfu clean gui
