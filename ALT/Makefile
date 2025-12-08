# Arduino Project Suite Makefile
# ================================

.DEFAULT_GOAL := help

# Include configuration files
include config/project_config.mk
include config/board_config.mk
include config/toolchain_config.mk

# Project directories
SRC_DIR := ALT/src
BUILD_DIR := build
LOG_DIR := logs
SCRIPTS_DIR := scripts

# Source files
PROJECTS := $(basename $(notdir $(wildcard $(SRC_DIR)/*.ino)))
HEX_FILES := $(addprefix $(BUILD_DIR)/,$(addsuffix /$(PROJECT_NAME).hex,$(PROJECTS)))
ELF_FILES := $(addprefix $(BUILD_DIR)/,$(addsuffix /$(PROJECT_NAME).elf,$(PROJECTS)))

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# ========== TARGETS ==========

.PHONY: all clean help setup test upload monitor dependencies

# Build all projects
all: setup dependencies $(PROJECTS)
	@echo "$(GREEN)✓ All projects built successfully$(NC)"

# Individual project targets
$(PROJECTS): %:
	@echo "$(BLUE)Building $@...$(NC)"
	@mkdir -p $(BUILD_DIR)/$@
	@$(SCRIPTS_DIR)/build.sh $(SRC_DIR)/$@.ino $(BOARD_TYPE) $(BUILD_DIR)/$@ 2>&1 | tee $(LOG_DIR)/build_$@.log
	@echo "$(GREEN)✓ $@ built successfully$(NC)"

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build directories...$(NC)"
	@rm -rf $(BUILD_DIR)/*
	@rm -rf $(LOG_DIR)/*.log
	@echo "$(GREEN)✓ Clean complete$(NC)"

# Setup project structure
setup:
	@echo "$(BLUE)Setting up project structure...$(NC)"
	@mkdir -p $(BUILD_DIR) $(LOG_DIR) config scripts
	@chmod +x $(SCRIPTS_DIR)/*.sh 2>/dev/null || true
	@echo "$(GREEN)✓ Setup complete$(NC)"

# Test all projects
test:
	@echo "$(BLUE)Running tests...$(NC)"
	@$(SCRIPTS_DIR)/test.sh 2>&1 | tee $(LOG_DIR)/test.log
	@echo "$(GREEN)✓ Tests complete$(NC)"

# Upload specific project
upload-%: %
	@echo "$(BLUE)Uploading $* to $(BOARD_TYPE)...$(NC)"
	@$(SCRIPTS_DIR)/upload.sh $(BUILD_DIR)/$*/$*.hex $(PORT) 2>&1 | tee $(LOG_DIR)/upload_$*.log
	@echo "$(GREEN)✓ $* uploaded successfully$(NC)"

# Upload all projects (to different boards)
upload-all: $(PROJECTS)
	@echo "$(YELLOW)Warning: This will upload all projects sequentially$(NC)"
	@for project in $(PROJECTS); do \
		echo "$(BLUE)Uploading $$project...$(NC)"; \
		$(SCRIPTS_DIR)/upload.sh $(BUILD_DIR)/$$project/$$project.hex $(PORT) 2>&1 | tee $(LOG_DIR)/upload_$$project.log; \
	done
	@echo "$(GREEN)✓ All projects uploaded$(NC)"

# Serial monitor
monitor:
	@echo "$(BLUE)Opening serial monitor on $(PORT)...$(NC)"
	@$(SCRIPTS_DIR)/monitor.sh $(PORT) $(BAUD_RATE)

# Check dependencies
dependencies:
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@$(SCRIPTS_DIR)/dependencies.sh
	@echo "$(GREEN)✓ Dependencies checked$(NC)"

# Generate documentation
docs:
	@echo "$(BLUE)Generating documentation...$(NC)"
	@doxygen Doxyfile 2>/dev/null || echo "$(YELLOW)Doxygen not found, skipping documentation$(NC)"
	@echo "$(GREEN)✓ Documentation generated$(NC)"

# List all available boards
list-boards:
	@echo "$(BLUE)Available board configurations:$(NC)"
	@echo "1. arduino:uno        - Arduino Uno"
	@echo "2. arduino:nano       - Arduino Nano"
	@echo "3. arduino:mega       - Arduino Mega 2560"
	@echo "4. arduino:leonardo   - Arduino Leonardo"
	@echo ""
	@echo "To change board: make set-board BOARD=arduino:mega"

# Set board configuration
set-board:
ifndef BOARD
	$(error BOARD is not set. Usage: make set-board BOARD=arduino:uno)
endif
	@echo "BOARD_TYPE := $(BOARD)" > config/board_config.mk
	@echo "$(GREEN)✓ Board set to $(BOARD)$(NC)"

# Help menu
help:
	@echo "$(BLUE)Arduino Project Suite Makefile$(NC)"
	@echo "$(BLUE)================================$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  make all           - Build all projects"
	@echo "  make led_blink     - Build specific project"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make setup         - Setup project structure"
	@echo "  make test          - Run tests"
	@echo "  make upload-led_blink - Upload specific project"
	@echo "  make upload-all    - Upload all projects"
	@echo "  make monitor       - Open serial monitor"
	@echo "  make dependencies  - Check system dependencies"
	@echo "  make docs          - Generate documentation"
	@echo "  make list-boards   - List available boards"
	@echo "  make set-board BOARD=arduino:uno - Change board"
	@echo "  make help          - Show this help"
	@echo ""
	@echo "$(GREEN)Current configuration:$(NC)"
	@echo "  Board: $(BOARD_TYPE)"
	@echo "  Port: $(PORT)"
	@echo "  Projects: $(PROJECTS)"
	@echo ""
	@echo "$(YELLOW)Example workflow:$(NC)"
	@echo "  1. make setup"
	@echo "  2. make dependencies"
	@echo "  3. make all"
	@echo "  4. make upload-led_blink"
	@echo "  5. make monitor"
