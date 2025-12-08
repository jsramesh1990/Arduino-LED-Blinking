#!/bin/bash

# Arduino Project Dependency Checker
# ===================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dependency status
ALL_DEPS_OK=true

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ALL_DEPS_OK=false
}

# Check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local required=${3:-true}
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -n1)
        print_success "$name: $version"
        return 0
    else
        if [ "$required" = "true" ]; then
            print_error "$name: Not installed"
            return 1
        else
            print_warning "$name: Not installed (optional)"
            return 0
        fi
    fi
}

# Check Arduino CLI installation
check_arduino_cli() {
    print_info "Checking Arduino CLI..."
    
    if command -v arduino-cli &> /dev/null; then
        local version=$(arduino-cli version 2>/dev/null | head -n1)
        print_success "Arduino CLI: $version"
        
        # Check if core is installed
        print_info "Checking Arduino core installation..."
        if arduino-cli core list 2>/dev/null | grep -q "arduino:avr"; then
            print_success "Arduino AVR core: Installed"
        else
            print_warning "Arduino AVR core: Not installed"
            print_info "To install: arduino-cli core install arduino:avr"
        fi
        
        return 0
    else
        print_error "Arduino CLI: Not installed"
        print_info "Installation options:"
        print_info "  1. Download from: https://arduino.github.io/arduino-cli/"
        print_info "  2. Install via package manager:"
        print_info "     Ubuntu: sudo apt-get install arduino-cli"
        print_info "     macOS: brew install arduino-cli"
        print_info "     Windows: choco install arduino-cli"
        return 1
    fi
}

# Check AVR toolchain
check_avr_toolchain() {
    print_info "Checking AVR toolchain..."
    
    local tools=("avr-gcc" "avr-g++" "avr-objcopy" "avr-objdump" "avr-size" "avrdude")
    
    for tool in "${tools[@]}"; do
        check_command "$tool" "$tool" true
    done
    
    # Check if tools are in PATH
    if ! which avr-gcc &> /dev/null; then
        print_warning "AVR toolchain may not be properly installed"
        print_info "Installation:"
        print_info "  Ubuntu: sudo apt-get install gcc-avr avr-libc avrdude"
        print_info "  macOS: brew install avr-gcc avrdude"
        print_info "  Windows: Install Arduino IDE (includes AVR tools)"
    fi
}

# Check required libraries
check_libraries() {
    print_info "Checking required libraries..."
    
    local libs=("Servo" "LiquidCrystal")
    
    if command -v arduino-cli &> /dev/null; then
        for lib in "${libs[@]}"; do
            if arduino-cli lib list 2>/dev/null | grep -q "^$lib "; then
                print_success "Library $lib: Installed"
            else
                print_warning "Library $lib: Not installed"
                print_info "To install: arduino-cli lib install $lib"
            fi
        done
    else
        print_warning "Cannot check libraries without Arduino CLI"
    fi
}

# Check Python dependencies (for advanced features)
check_python_deps() {
    print_info "Checking Python dependencies..."
    
    if command -v python3 &> /dev/null; then
        print_success "Python3: $(python3 --version 2>&1)"
        
        # Check for useful Python packages
        local packages=("pyserial" "colorama")
        
        for pkg in "${packages[@]}"; do
            if python3 -c "import $pkg" 2>/dev/null; then
                print_success "Python package $pkg: Installed"
            else
                print_warning "Python package $pkg: Not installed"
                print_info "To install: pip3 install $pkg"
            fi
        done
    else
        print_warning "Python3: Not installed (optional for advanced features)"
    fi
}

# Check serial port tools
check_serial_tools() {
    print_info "Checking serial communication tools..."
    
    local tools=(
        "screen:Screen"
        "minicom:Minicom"
        "picocom:Picocom"
        "cu:Cu"
    )
    
    for tool_info in "${tools[@]}"; do
        local cmd=$(echo "$tool_info" | cut -d: -f1)
        local name=$(echo "$tool_info" | cut -d: -f2)
        check_command "$cmd" "$name" false
    done
}

# Check build system
check_build_system() {
    print_info "Checking build system..."
    
    check_command "make" "GNU Make" true
    check_command "cmake" "CMake" false
    check_command "git" "Git" false
    
    # Check for required directories
    if [ -d "ALT/src" ]; then
        print_success "Project structure: OK"
    else
        print_error "Project structure: Missing ALT/src directory"
    fi
}

# Check operating system
check_os() {
    print_info "Checking operating system..."
    
    case "$(uname -s)" in
        Linux)
            print_success "OS: Linux ($(lsb_release -d 2>/dev/null | cut -f2 || uname -r))"
            ;;
        Darwin)
            print_success "OS: macOS ($(sw_vers -productVersion))"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            print_success "OS: Windows (Cygwin/MSYS)"
            ;;
        *)
            print_warning "OS: $(uname -s) (Unknown)"
            ;;
    esac
}

# Main function
main() {
    echo -e "${BLUE}=== Arduino Project Dependency Check ===${NC}"
    echo ""
    
    # Run all checks
    check_os
    echo ""
    
    check_build_system
    echo ""
    
    check_arduino_cli
    echo ""
    
    check_avr_toolchain
    echo ""
    
    check_libraries
    echo ""
    
    check_serial_tools
    echo ""
    
    check_python_deps
    echo ""
    
    # Summary
    echo -e "${BLUE}=== SUMMARY ===${NC}"
    if [ "$ALL_DEPS_OK" = true ]; then
        echo -e "${GREEN}✓ All required dependencies are installed${NC}"
        echo -e "${GREEN}You can now run: make setup && make all${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some required dependencies are missing${NC}"
        echo -e "${YELLOW}Please install the missing dependencies and run this check again${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
