#!/bin/bash

# Arduino Upload Script
# ======================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if file exists
check_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi
    return 0
}

# Check if port is available
check_port() {
    local port=$1
    
    if [ -z "$port" ]; then
        print_error "No port specified. Auto-detecting..."
        port=$(find_arduino_port)
        if [ -z "$port" ]; then
            print_error "No Arduino port found. Please connect Arduino or specify port manually."
            return 1
        fi
    fi
    
    if [ ! -c "$port" ]; then
        print_error "Port $port does not exist or is not a character device"
        return 1
    fi
    
    print_info "Using port: $port"
    return 0
}

# Find Arduino port automatically
find_arduino_port() {
    # Try common Arduino ports
    for port in /dev/ttyUSB* /dev/ttyACM* /dev/tty.wchusbserial* /dev/tty.usbserial*; do
        if [ -c "$port" ]; then
            echo "$port"
            return 0
        fi
    done
    echo ""
    return 1
}

# Upload hex file
upload_hex() {
    local hex_file=$1
    local port=$2
    local board_fqbn=${3:-"arduino:avr:uno"}
    
    print_info "Uploading $hex_file to board $board_fqbn on port $port"
    
    # Upload using Arduino CLI
    arduino-cli upload \
        --fqbn "$board_fqbn" \
        --port "$port" \
        --input-file "$hex_file" \
        --verbose
    
    local upload_status=$?
    
    if [ $upload_status -eq 0 ]; then
        print_success "Upload completed successfully"
        return 0
    else
        print_error "Upload failed with status $upload_status"
        return 1
    fi
}

# Upload using avrdude directly
upload_avrdude() {
    local hex_file=$1
    local port=$2
    local mcu=${3:-"atmega328p"}
    local programmer=${4:-"arduino"}
    local baud=${5:-"115200"}
    
    print_info "Uploading using avrdude directly..."
    
    avrdude -v -p "$mcu" -c "$programmer" \
        -P "$port" -b "$baud" \
        -D -U "flash:w:$hex_file:i"
    
    local avrdude_status=$?
    
    return $avrdude_status
}

# Verify upload
verify_upload() {
    local hex_file=$1
    local port=$2
    
    print_info "Verifying upload..."
    
    # Simple verification - check if we can open serial port
    # In a real scenario, you might want to send a verification command
    if [ -c "$port" ]; then
        print_success "Port $port is accessible"
        return 0
    else
        print_error "Cannot access port $port for verification"
        return 1
    fi
}

# Main execution
main() {
    # Check for required arguments
    if [ $# -lt 2 ]; then
        print_error "Usage: $0 <hex_file> <port> [board_fqbn]"
        print_info "Example: $0 build/led_blink/led_blink.hex /dev/ttyUSB0"
        print_info "Example: $0 build/led_blink/led_blink.hex /dev/ttyUSB0 arduino:avr:uno"
        exit 1
    fi
    
    local hex_file=$1
    local port=$2
    local board_fqbn=${3:-"arduino:avr:uno"}
    
    # Check if Arduino CLI is available
    if ! command -v arduino-cli &> /dev/null; then
        print_warning "Arduino CLI not found, trying avrdude directly"
        
        # Extract MCU from board FQBN
        local mcu="atmega328p"
        if [[ "$board_fqbn" == *"mega"* ]]; then
            mcu="atmega2560"
        elif [[ "$board_fqbn" == *"nano"* ]]; then
            mcu="atmega328p"
        fi
        
        upload_avrdude "$hex_file" "$port" "$mcu"
        local upload_status=$?
    else
        upload_hex "$hex_file" "$port" "$board_fqbn"
        local upload_status=$?
    fi
    
    if [ $upload_status -eq 0 ]; then
        # Give the Arduino time to reset
        sleep 2
        
        # Verify upload
        verify_upload "$hex_file" "$port"
        
        print_success "Upload process completed successfully!"
        print_info "You can now open the serial monitor with: make monitor"
    else
        print_error "Upload process failed!"
        
        # Troubleshooting tips
        print_info "Troubleshooting tips:"
        print_info "1. Check if Arduino is connected properly"
        print_info "2. Check if the correct port is selected"
        print_info "3. Check if another program is using the serial port"
        print_info "4. Try resetting the Arduino"
        print_info "5. Check board and programmer settings"
        
        exit 1
    fi
}

# Run main function
main "$@"
