#!/bin/bash

# Arduino Serial Monitor Script
# =============================

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

# Find Arduino port automatically
find_arduino_port() {
    print_info "Looking for Arduino board..."
    
    # Common Arduino ports on different systems
    local ports=(
        /dev/ttyUSB*
        /dev/ttyACM*
        /dev/tty.wchusbserial*
        /dev/tty.usbserial*
        /dev/tty.usbmodem*
    )
    
    for pattern in "${ports[@]}"; do
        for port in $pattern; do
            if [ -c "$port" ]; then
                print_success "Found Arduino at: $port"
                echo "$port"
                return 0
            fi
        done
    done
    
    print_error "No Arduino board found automatically"
    return 1
}

# Check if port is valid
check_port() {
    local port=$1
    
    if [ ! -c "$port" ]; then
        print_error "Port $port is not a valid character device"
        return 1
    fi
    
    # Check if we have permission to access the port
    if [ ! -r "$port" ] || [ ! -w "$port" ]; then
        print_error "Insufficient permissions for port $port"
        print_info "Try running with sudo or add your user to the dialout group:"
        print_info "  sudo usermod -a -G dialout $USER"
        return 1
    fi
    
    return 0
}

# Start serial monitor
start_monitor() {
    local port=$1
    local baud=$2
    local monitor_tool=$3
    
    print_info "Starting serial monitor on $port at $baud baud"
    
    case $monitor_tool in
        "arduino-cli")
            arduino-cli monitor \
                --port "$port" \
                --config baudrate="$baud"
            ;;
        "screen")
            screen "$port" "$baud"
            ;;
        "minicom")
            minicom -D "$port" -b "$baud"
            ;;
        "picocom")
            picocom "$port" -b "$baud"
            ;;
        "cu")
            cu -l "$port" -s "$baud"
            ;;
        *)
            # Use simple cat for basic monitoring
            print_info "Using simple serial monitor (Ctrl+C to exit)"
            stty -F "$port" "$baud" raw -echo
            cat "$port"
            ;;
    esac
}

# List available serial ports
list_ports() {
    print_info "Available serial ports:"
    echo "------------------------"
    
    for port in /dev/ttyUSB* /dev/ttyACM* /dev/tty.wchusbserial* /dev/tty.usbserial* 2>/dev/null; do
        if [ -c "$port" ]; then
            # Get port info if possible
            local device_info=""
            if command -v udevadm &> /dev/null; then
                device_info=$(udevadm info -q property -n "$port" | grep -E "ID_MODEL|ID_VENDOR" | cut -d'=' -f2 | tr '\n' ' ')
            fi
            
            echo -e "  ${GREEN}$port${NC} - $device_info"
        fi
    done
    
    if [ -z "$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)" ]; then
        print_error "No serial ports found"
    fi
}

# Main execution
main() {
    local port=""
    local baud=9600
    local monitor_tool=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port="$2"
                shift 2
                ;;
            -b|--baud)
                baud="$2"
                shift 2
                ;;
            -t|--tool)
                monitor_tool="$2"
                shift 2
                ;;
            -l|--list)
                list_ports
                exit 0
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -p, --port PORT    Serial port (default: auto-detect)"
                echo "  -b, --baud RATE    Baud rate (default: 9600)"
                echo "  -t, --tool TOOL    Monitor tool: arduino-cli, screen, minicom, picocom, cu"
                echo "  -l, --list         List available serial ports"
                echo "  -h, --help         Show this help"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # If port not specified, try to auto-detect
    if [ -z "$port" ]; then
        port=$(find_arduino_port)
        if [ $? -ne 0 ]; then
            print_error "Please specify a port manually:"
            echo "  $0 -p /dev/ttyUSB0"
            list_ports
            exit 1
        fi
    fi
    
    # Check port validity
    check_port "$port"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # Determine which monitor tool to use
    if [ -z "$monitor_tool" ]; then
        if command -v arduino-cli &> /dev/null; then
            monitor_tool="arduino-cli"
        elif command -v screen &> /dev/null; then
            monitor_tool="screen"
        elif command -v minicom &> /dev/null; then
            monitor_tool="minicom"
        elif command -v picocom &> /dev/null; then
            monitor_tool="picocom"
        elif command -v cu &> /dev/null; then
            monitor_tool="cu"
        else
            monitor_tool="simple"
        fi
    fi
    
    print_info "Using monitor tool: $monitor_tool"
    
    # Trap Ctrl+C to clean up
    trap 'print_info "Serial monitor stopped"' INT TERM
    
    # Start the monitor
    start_monitor "$port" "$baud" "$monitor_tool"
    
    # If we get here, the monitor was stopped
    print_info "Serial monitor closed"
}

# Run main function
main "$@"
