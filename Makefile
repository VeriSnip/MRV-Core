VTbuild_DIR ?= $(PWD)/VT-Tool
MyUtils_DIR ?= $(PWD)/Utils-Tool

PROJECT_NAME ?= core

# MyVT variables used by MyUtils
QUIET := 1

# FPGA/Board variables used by MyUtils
FPGA_TOP_MODULES := _fpga
PROJECT_FPGA_TOP := $(PROJECT_NAME)_fpga
PROJECT_FPGA_DIR = $(PROJECT_RTL_DIR)/fpga
SUPPORTED_BOARDS := IceSugar_pro DE10_Lite ULX3S
BOARD ?= ULX3S

# Simulation variables used by MyUtils
SUPPORTED_SIMULATORS := QuestaSim
SIMULATOR := QuestaSim
## Comment the following line to test only the UART core (uses myuart_tb by default).
PROJECT_SIM_TOP := $(PROJECT_NAME)_fpga_tb

include $(MyUtils_DIR)/utils.mk