set_property BITSTREAM.Config.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property IOSTANDARD LVCMOS33 [get_port { uid_scl uid_sda }]

set_property PACKAGE_PIN W5 [get_ports {uid_scl}]
set_property PACKAGE_PIN V5  [get_ports {uid_sda}]

false_path { uid_scl uid_sda } osc_clk
