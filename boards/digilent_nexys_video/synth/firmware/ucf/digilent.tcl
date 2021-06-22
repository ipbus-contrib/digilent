#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------


# Bitstream config options
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


# System clock (200MHz)
create_clock -period 20.000 -name osc_clk [get_ports osc_clk]
set_property IOSTANDARD LVCMOS33 [get_ports osc_clk]
set_property PACKAGE_PIN R4 [get_ports osc_clk]

# Voltage Adjust
set_property IOSTANDARD LVCMOS25 [get_ports {set_vadj}]
set_property IOSTANDARD LVCMOS25 [get_ports {vadj_en}]
set_property PACKAGE_PIN AA13 [get_ports {set_vadj[0]}]
set_property PACKAGE_PIN AB17 [get_ports {set_vadj[1]}]
set_property PACKAGE_PIN V14 [get_ports {vadj_en}]

# RGMII pin constraints
set_property IOSTANDARD LVCMOS33 [get_ports {phy_rstn}]
set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_*}]
set_property PACKAGE_PIN Y12 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN W12 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN W11 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN Y11 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN V10 [get_ports {rgmii_tx_ctl}]
set_property PACKAGE_PIN AA14 [get_ports {rgmii_txc}]
set_property PACKAGE_PIN AB16 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN AA15 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN AB15 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN AB11 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN W10 [get_ports {rgmii_rx_ctl}]
set_property PACKAGE_PIN V13 [get_ports {rgmii_rxc}]
set_property PACKAGE_PIN U7 [get_ports {phy_rstn}]
false_path {phy_rstn} osc_clk


# LED pin constraints
set_property IOSTANDARD LVCMOS25 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN T14 [get_ports {leds[0]}] 
set_property PACKAGE_PIN T15 [get_ports {leds[1]}] 
set_property PACKAGE_PIN T16 [get_ports {leds[2]}] 
set_property PACKAGE_PIN U16 [get_ports {leds[3]}]
false_path {leds[*]} osc_clk


# Configuration pins. On bank 16. Programmable voltage rail VADJ. FMC connector
# on same bank.
if { [llength [get_ports {cfg[*]}]] > 0} {
  set_property IOSTANDARD LVCMOS25 [get_ports {cfg[*]}]
  set_property PULLUP TRUE [get_ports {cfg[*]}]
  set_property PACKAGE_PIN E22 [get_ports {cfg[0]}]
  set_property PACKAGE_PIN F21 [get_ports {cfg[1]}]
  set_property PACKAGE_PIN G21 [get_ports {cfg[2]}]
  set_property PACKAGE_PIN G22 [get_ports {cfg[3]}]
}

# UART pins (not always used).
set_property IOSTANDARD LVCMOS33 [get_port {FTDI_*}]
set_property PACKAGE_PIN AA19 [get_port {FTDI_RXD}]
set_property PACKAGE_PIN V18 [get_port {FTDI_TXD}]

## Configuration options.
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# Clock constraints
set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

# Ethernet clock
create_generated_clock -name clk_125 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_125_90 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

# 200 Mhz derived clock
create_generated_clock -name clk_200 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT4]

# 40 Mhz derived clock
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT5]


set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]
