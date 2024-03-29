#################################################################################################
#  < NEO430 Application Compile Script - Linux / Windows Powershell / Windows Linux Subsystem > #
# ********************************************************************************************* #
# This file is part of the NEO430 Processor project: https://github.com/stnolting/neo430        #
# Copyright by Stephan Nolting: stnolting@gmail.com                                             #
#                                                                                               #
# This source file may be used and distributed without restriction provided that this copyright #
# statement is not removed from the file and that any derivative work contains the original     #
# copyright notice and the associated disclaimer.                                               #
#                                                                                               #
# This source file is free software; you can redistribute it and/or modify it under the terms   #
# of the GNU Lesser General Public License as published by the Free Software Foundation,        #
# either version 3 of the License, or (at your option) any later version.                       #
#                                                                                               #
# This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;      #
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     #
# See the GNU Lesser General Public License for more details.                                   #
#                                                                                               #
# You should have received a copy of the GNU Lesser General Public License along with this      #
# source; if not, download it from https://www.gnu.org/licenses/lgpl-3.0.en.html                #
# ********************************************************************************************* #
# Stephan Nolting, Hannover, Germany                                                 04.10.2019 #
#################################################################################################


#-------------------------------------------------------------------------------
# USER CONFIGURATION
#-------------------------------------------------------------------------------
# Compiler effort (-Os = optimize for size)
EFFORT = -Os

# User's application sources (add additional files here)
APP_SRC = main.c ../lib/source/neo430_i2c.c ../lib/source/neo430_wishbone_mac_ip.c

# User's application include folders (don't forget the '-I' before each entry)
APP_INC = -I . -I ../lib/include
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
# NEO430 framework
#-------------------------------------------------------------------------------
# This is a bit fragile ... point to neo430 checked out from github.
NEO430_REPO_PATH=../../../neo430/sw
# Path to NEO430 linker script and startup file
NEO430_COM_PATH=$(NEO430_REPO_PATH)/common
# Path to main NEO430 library include files
NEO430_INC_PATH=$(NEO430_REPO_PATH)/lib/neo430/include
# Path to main NEO430 library source files
NEO430_SRC_PATH=$(NEO430_REPO_PATH)/lib/neo430/source
# Path to NEO430 executable generator
NEO430_EXE_PATH=$(NEO430_REPO_PATH)/tools/image_gen

# Path to NEO430 core rtl folder
NEO430_RTL_PATH=../../firmware/hdl
# Path to location of Neo430 linker script - edit this if you want to change ROM,RAM size
NEO430_LINKER_SCRIPT_PATH=../common


#-------------------------------------------------------------------------------
# Add NEO430 sources to input SRCs
#-------------------------------------------------------------------------------
APP_SRC += $(wildcard $(NEO430_SRC_PATH)/*.c)


#-------------------------------------------------------------------------------
# Make defaults
#-------------------------------------------------------------------------------
.SUFFIXES:
.PHONY: all
.DEFAULT_GOAL := help


#-------------------------------------------------------------------------------
# Application output definitions
#-------------------------------------------------------------------------------
APP_BIN = main.bin
APP_ASM = main.s

APPLICATION_IMAGE_FNAME = neo430_application_image_macprom.vhd

compile: $(APP_ASM) $(APP_BIN)
install: $(APP_ASM) $(APPLICATION_IMAGE_FNAME)
all:     $(APP_ASM) $(APP_BIN) $(APPLICATION_IMAGE_FNAME)

# define all object files
OBJ = $(APP_SRC:.c=.o)


#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------
#C ompiler tools
AS        = msp430-elf-as
CC        = msp430-elf-gcc
LD        = msp430-elf-ld
STRIP     = msp430-elf-strip
OBJDUMP   = msp430-elf-objdump
OBJCOPY   = msp430-elf-objcopy
SIZE      = msp430-elf-size
IMAGE_GEN = $(NEO430_EXE_PATH)/image_gen

# Compiler flags
CC_OPTS = -mcpu=msp430 -pipe -Wall -Xassembler --mY -mhwmult=none -fno-delete-null-pointer-checks
CC_OPTS += -Wl,-static -mrelax -minrt -nostartfiles -fdata-sections -ffunction-sections -Xlinker --gc-sections

# Linker flags
LD_OPTS = -mcpu=msp430 -Wl,--gc-sections -mrelax -minrt -nostartfiles


#-------------------------------------------------------------------------------
# PC Host Compiler
#-------------------------------------------------------------------------------
CC_X86 = g++ -Wall -O -g


#-------------------------------------------------------------------------------
# Tool Targets
#-------------------------------------------------------------------------------
# install/compile tools
$(IMAGE_GEN): $(NEO430_EXE_PATH)/main.cpp
	@echo Compiling $(IMAGE_GEN)
	@$(CC_X86) $< -o $(IMAGE_GEN)

  
#-------------------------------------------------------------------------------
# Application Targets
#-------------------------------------------------------------------------------
# Assemble startup code
crt0.elf: $(NEO430_COM_PATH)/crt0.asm
	@$(AS) -mY -mcpu=msp430 $< -o $@

# Compile app sources
# CFLAGS can be passed as argument to make ( e.g. CFLAGS=-DFORCE_RARP=1 )
$(OBJ): %.o : %.c crt0.elf
	@$(CC) -c $(CC_OPTS) $(CFLAGS) $(EFFORT) -I $(NEO430_INC_PATH) $(APP_INC) $< -o $@

# Link object files
main.elf: $(OBJ)
	@$(CC) $(LD_OPTS) $(EFFORT) -I $(NEO430_INC_PATH) $(APP_INC) -T $(NEO430_LINKER_SCRIPT_PATH)/neo430_linker_script.x $(OBJ) -o $@ -lm
	@echo Memory utilization:
	@$(SIZE) main.elf

# Generate final executable (from .image section only)
image.dat: main.elf
	@$(OBJCOPY) -I elf32-little $< -j .text   -O binary text.dat
	@$(OBJCOPY) -I elf32-little $< -j .rodata -O binary rodata.dat
	@$(OBJCOPY) -I elf32-little $< -j .data   -O binary data.dat
	@cat text.dat rodata.dat data.dat > $@
	@rm -f text.dat rodata.dat data.dat

# Assembly listing file (for debugging)
$(APP_ASM): main.elf
	@$(OBJDUMP) -D -S -z  $< > $@
	@if grep -qR "dadd" $@; then echo "NEO430: WARNING! 'DADD' instruction might be used! Make sure it is synthesized!"; fi

# Generate NEO430 executable image for bootloader update
$(APP_BIN): image.dat $(IMAGE_GEN)
	@$(IMAGE_GEN) -app_bin $< $@

# Generate NEO430 executable VHDL boot image
$(APPLICATION_IMAGE_FNAME): image.dat $(IMAGE_GEN)
	@$(IMAGE_GEN) -app_img $< $@
	@echo Installing application image to $(NEO430_RTL_PATH)/$(APPLICATION_IMAGE_FNAME)
	@cp $(APPLICATION_IMAGE_FNAME) $(NEO430_RTL_PATH)/.
	@rm -f $(APPLICATION_IMAGE_FNAME)


#-------------------------------------------------------------------------------
# Help
#-------------------------------------------------------------------------------
help:
	@echo "NEO430 Application Compilation Script"
	@echo "Make sure to add the absolute path of the msp430-gcc bin folder to your PATH variable."
	@echo "Targets:"
	@echo " help      - show this text"
	@echo " compile   - compile and generate *.bin executable for upload via bootloader"
	@echo " install   - compile, generate and install VHDL boot image"
	@echo " all       - compile and generate *.bin executable for upload via bootloader and generate and install VHDL boot image"
	@echo " clean     - clean up project"
	@echo " clean_all - clean up project, core libraries and helper tools"


#-------------------------------------------------------------------------------
# Clean up
#-------------------------------------------------------------------------------
clean:
	@rm -f *.elf *.o *.dat *.vhd *.s *.bin

clean_all:
	@rm -f $(OBJ) *.elf *.dat *.bin *.vhd *.s $(IMAGE_GEN)

  
#-------------------------------------------------------------------------------
# eof
