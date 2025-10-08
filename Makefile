MyUtils_DIR ?= $(PWD)/submodules/Utils-Tool

PROJECT_NAME ?= RV_core

# MyVT variables used by MyUtils
QUIET := 1
#DEBUG := 1

# FPGA/Board variables used by MyUtils
FPGA_TOP_MODULES := _fpga
PROJECT_FPGA_TOP := $(PROJECT_NAME)_fpga
PROJECT_FPGA_DIR = $(PROJECT_RTL_DIR)/fpga
SUPPORTED_BOARDS := IceSugar_pro DE10_Lite ULX3S
BOARD ?= IceSugar_pro

# Simulation variables used by MyUtils
SUPPORTED_SIMULATORS := IVerilog
SIMULATOR := IVerilog
## Comment the following line to test only the UART core (uses myuart_tb by default).
PROJECT_SIM_TOP := $(PROJECT_NAME)_tb

include $(MyUtils_DIR)/utils.mk