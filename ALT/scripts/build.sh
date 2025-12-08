#!/bin/bash

# Arduino Project Builder Script
# ================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Arduino CLI is installed
check_arduino_cli() {
    if ! command -v arduino-cli &> /dev/null; then
        print_error "Arduino CLI not found. Please install it first."
        print_info "Installation guide: https://arduino.github.io/arduino-cli/"
        exit 1
    fi
}

# Check if board is installed
check_board_installed() {
    local board=$1
    if ! arduino-cli board listall | grep -q "$board"; then
        print_warning "Board $board not installed. Installing..."
        arduino-cli core install "$board"
        if [ $? -ne 0 ]; then
            print_error "Failed to install board $board"
            exit 1
        fi
        print_success "Board $board installed successfully"
    fi
}

# Build project
build_project() {
    local sketch=$1
    local board=$2
    local output_dir=$3
    
    print_info "Building $sketch for board $board"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Compile using Arduino CLI
    arduino-cli compile \
        --fqbn "$board" \
        --build-path "$output_dir" \
        --build-cache-path "$output_dir/cache" \
        --warnings all \
        --verbose \
        "$sketch"
    
    local build_status=$?
    
    if [ $build_status -eq 0 ]; then
        print_success "Build completed successfully"
        
        # Copy generated files
        local sketch_name=$(basename "$sketch" .ino)
        cp "$output_dir/$sketch_name.ino.hex" "$output_dir/$sketch_name.hex" 2>/dev/null || true
        cp "$output_dir/$sketch_name.ino.elf" "$output_dir/$sketch_name.elf" 2>/dev/null || true
        
        # Generate size report
        generate_size_report "$output_dir/$sketch_name.elf" "$output_dir"
        
        # Generate disassembly
        generate_disassembly "$output_dir/$sketch_name.elf" "$output_dir"
        
        return 0
    else
        print_error "Build failed with status $build_status"
        return 1
    fi
}

# Generate size report
generate_size_report() {
    local elf_file=$1
    local output_dir=$2
    
    if [ -f "$elf_file" ]; then
        avr-size --mcu=atmega328p -C "$elf_file" > "$output_dir/size_report.txt" 2>/dev/null || true
        print_info "Size report generated: $output_dir/size_report.txt"
    fi
}

# Generate disassembly
generate_disassembly() {
    local elf_file=$1
    local output_dir=$2
    
    if [ -f "$elf_file" ]; then
        avr-objdump -S "$elf_file" > "$output_dir/disassembly.asm" 2>/dev/null || true
        print_info "Disassembly generated: $output_dir/disassembly.asm"
    fi
}

# Clean build directory
clean_build() {
    local output_dir=$1
    print_info "Cleaning build directory: $output_dir"
    rm -rf "$output_dir"
    mkdir -p "$output_dir"
}

# Main execution
main() {
    # Check for required arguments
    if [ $# -lt 3 ]; then
        print_error "Usage: $0 <sketch_file> <board_fqbn> <output_dir>"
        print_info "Example: $0 ALT/src/led_blink.ino arduino:avr:uno build/led_blink"
        exit 1
    fi
    
    local sketch_file=$1
    local board_fqbn=$2
    local output_dir=$3
    
    # Check if sketch file exists
    if [ ! -f "$sketch_file" ]; then
        print_error "Sketch file not found: $sketch_file"
        exit 1
    fi
    
    # Check Arduino CLI
    check_arduino_cli
    
    # Check if board is installed
    check_board_installed "$board_fqbn"
    
    # Clean previous build
    clean_build "$output_dir"
    
    # Build project
    build_project "$sketch_file" "$board_fqbn" "$output_dir"
    
    if [ $? -eq 0 ]; then
        print_success "Build process completed!"
        print_info "Output directory: $output_dir"
        print_info "Generated files:"
        ls -la "$output_dir" | grep -E "\.(hex|elf|txt|asm)$"
    else
        print_error "Build process failed!"
        exit 1
    fi
}

# Run main function
main "$@"
