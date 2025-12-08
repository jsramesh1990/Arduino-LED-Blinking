# Project Configuration
# =====================

# Project name
PROJECT_NAME := arduino_suite

# Version
VERSION := 1.0.0

# Author
AUTHOR := Arduino Projects Team

# Build mode (debug/release)
BUILD_MODE := debug

# Debug flags
ifeq ($(BUILD_MODE),debug)
    CFLAGS += -g -DDEBUG
endif

# Optimization level
OPTIMIZATION := -Os

# Output verbosity
VERBOSE := 0
ifeq ($(VERBOSE),1)
    Q := 
    V := 1
else
    Q := @
    V := 0
endif
