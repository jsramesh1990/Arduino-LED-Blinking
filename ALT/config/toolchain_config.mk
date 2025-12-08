# Toolchain Configuration
# =======================

# Arduino CLI tool
ARDUINO_CLI ?= arduino-cli

# Check if Arduino CLI exists
ifeq (, $(shell which $(ARDUINO_CLI)))
    $(error "Arduino CLI not found. Please install it: https://arduino.github.io/arduino-cli/")
endif

# Compiler tools
CC := avr-gcc
CXX := avr-g++
OBJCOPY := avr-objcopy
OBJDUMP := avr-objdump
SIZE := avr-size

# Toolchain paths
AVR_ROOT ?= /usr/share/arduino/hardware/tools/avr
AVR_BIN := $(AVR_ROOT)/bin
AVR_INCLUDE := $(AVR_ROOT)/avr/include

# Compiler flags
CFLAGS += -mmcu=$(MCU) $(OPTIMIZATION) $(BOARD_FLAGS)
CFLAGS += -Wall -Wextra -Werror
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -std=gnu11

# C++ flags
CXXFLAGS += -mmcu=$(MCU) $(OPTIMIZATION) $(BOARD_FLAGS)
CXXFLAGS += -Wall -Wextra -Werror
CXXFLAGS += -ffunction-sections -fdata-sections
CXXFLAGS += -fno-exceptions -fno-threadsafe-statics
CXXFLAGS += -std=gnu++11

# Linker flags
LDFLAGS += -mmcu=$(MCU) $(OPTIMIZATION)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--print-memory-usage

# Size flags
SIZE_FLAGS := --mcu=$(MCU) -C
