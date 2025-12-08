# Board Configuration
# ===================

# Default board (Arduino Uno)
BOARD_TYPE := arduino:avr:uno

# Board CPU frequency
F_CPU := 16000000L

# MCU type
MCU := atmega328p

# Port (auto-detected or manual)
PORT ?= $(shell ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -n1)

# Baud rate for serial monitor
BAUD_RATE := 9600

# Programmer settings
PROGRAMMER := arduino
PROGRAMMER_PORT := $(PORT)
PROGRAMMER_BAUD := 115200

# Board-specific flags
BOARD_FLAGS := -D$(MCU) -DF_CPU=$(F_CPU)

# Memory settings
FLASH_SIZE := 32256
SRAM_SIZE := 2048
EEPROM_SIZE := 1024
