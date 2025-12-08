#!/bin/bash

# Arduino Test Script
# ====================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

print_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_summary() {
    echo -e "\n${BLUE}=== TEST SUMMARY ===${NC}"
    echo -e "Total tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Some tests failed!${NC}"
        return 1
    fi
}

# Test file syntax
test_syntax() {
    local file=$1
    local test_name=$2
    
    print_info "Testing syntax: $test_name"
    
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Check for Arduino-specific syntax issues
    if grep -q "void main" "$file"; then
        print_error "$test_name: Found 'void main' instead of 'void setup/loop'"
        return 1
    fi
    
    # Check for missing semicolons (basic check)
    if tail -1 "$file" | grep -q "^[^;]*[^;}{]$"; then
        print_warning "$test_name: Possible missing semicolon at end of file"
    fi
    
    # Verify basic structure
    if grep -q "void setup" "$file" && grep -q "void loop" "$file"; then
        print_success "$test_name: Syntax check passed"
        return 0
    else
        print_error "$test_name: Missing setup() or loop() function"
        return 1
    fi
}

# Test compilation
test_compilation() {
    local sketch=$1
    local test_name=$2
    
    print_info "Testing compilation: $test_name"
    
    # Create temporary build directory
    local temp_dir=$(mktemp -d)
    
    # Try to compile with arduino-cli
    if command -v arduino-cli &> /dev/null; then
        arduino-cli compile \
            --fqbn arduino:avr:uno \
            --build-path "$temp_dir" \
            --warnings all \
            "$sketch" > "$temp_dir/compile.log" 2>&1
        
        local compile_status=$?
        
        if [ $compile_status -eq 0 ]; then
            # Check for warnings
            if grep -q "warning:" "$temp_dir/compile.log"; then
                print_warning "$test_name: Compilation succeeded with warnings"
                grep "warning:" "$temp_dir/compile.log" | head -5
            else
                print_success "$test_name: Compilation succeeded"
            fi
            
            # Check memory usage
            if [ -f "$temp_dir/$(basename $sketch .ino).ino.elf" ]; then
                avr-size --mcu=atmega328p -C \
                    "$temp_dir/$(basename $sketch .ino).ino.elf" \
                    > "$temp_dir/memory.log" 2>&1 || true
                    
                print_info "$test_name memory usage:"
                tail -3 "$temp_dir/memory.log"
            fi
            
            rm -rf "$temp_dir"
            return 0
        else
            print_error "$test_name: Compilation failed"
            echo "=== Compilation errors ==="
            grep -A 5 -B 5 "error:" "$temp_dir/compile.log" || cat "$temp_dir/compile.log"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_warning "$test_name: Arduino CLI not found, skipping compilation test"
        return 0
    fi
}

# Test file structure
test_structure() {
    local file=$1
    local test_name=$2
    
    print_info "Testing structure: $test_name"
    
    # Check for required sections
    local has_comment_header=$(grep -c "^\s*/\*\*" "$file")
    local has_setup=$(grep -c "void setup" "$file")
    local has_loop=$(grep -c "void loop" "$file")
    
    if [ $has_comment_header -lt 1 ]; then
        print_warning "$test_name: Missing documentation header"
    fi
    
    if [ $has_setup -eq 0 ]; then
        print_error "$test_name: Missing setup() function"
        return 1
    fi
    
    if [ $has_loop -eq 0 ]; then
        print_error "$test_name: Missing loop() function"
        return 1
    fi
    
    print_success "$test_name: Structure check passed"
    return 0
}

# Test dependencies
test_dependencies() {
    local file=$1
    local test_name=$2
    
    print_info "Testing dependencies: $test_name"
    
    # Check for required libraries
    if grep -q "#include <Servo.h>" "$file"; then
        print_info "$test_name: Requires Servo library"
        # Check if Servo library is installed
        if command -v arduino-cli &> /dev/null; then
            if arduino-cli lib list | grep -q "Servo"; then
                print_success "$test_name: Servo library available"
            else
                print_warning "$test_name: Servo library not installed"
            fi
        fi
    fi
    
    if grep -q "#include <LiquidCrystal.h>" "$file"; then
        print_info "$test_name: Requires LiquidCrystal library"
    fi
    
    print_success "$test_name: Dependency check passed"
    return 0
}

# Test project-specific requirements
test_project_specific() {
    local file=$1
    local test_name=$2
    
    print_info "Testing project-specific: $test_name"
    
    case $test_name in
        led_blink)
            # Should have LED_PIN constant
            if grep -q "LED_PIN" "$file"; then
                print_success "$test_name: Has LED_PIN constant"
            else
                print_warning "$test_name: Missing LED_PIN constant"
            fi
            ;;
        traffic_light)
            # Should have multiple pin definitions
            local pin_count=$(grep -c "const int.*PIN" "$file")
            if [ $pin_count -ge 3 ]; then
                print_success "$test_name: Has multiple pin definitions"
            else
                print_warning "$test_name: Expected multiple pin definitions"
            fi
            ;;
        pir_motion_alarm)
            # Should have PIR_PIN
            if grep -q "PIR_PIN" "$file"; then
                print_success "$test_name: Has PIR_PIN constant"
            else
                print_warning "$test_name: Missing PIR_PIN constant"
            fi
            ;;
    esac
    
    return 0
}

# Run all tests for a project
test_project() {
    local sketch=$1
    local test_name=$(basename "$sketch" .ino)
    
    ((TESTS_TOTAL++))
    
    echo -e "\n${BLUE}=== Testing $test_name ===${NC}"
    
    # Run individual tests
    test_syntax "$sketch" "$test_name"
    test_structure "$sketch" "$test_name"
    test_dependencies "$sketch" "$test_name"
    test_project_specific "$sketch" "$test_name"
    test_compilation "$sketch" "$test_name"
}

# Main execution
main() {
    echo -e "${BLUE}=== Arduino Project Test Suite ===${NC}"
    echo -e "Starting tests...\n"
    
    # Get all Arduino sketches
    local sketches=$(find ALT/src -name "*.ino" -type f)
    
    if [ -z "$sketches" ]; then
        print_error "No Arduino sketches found in ALT/src/"
        exit 1
    fi
    
    # Test each sketch
    for sketch in $sketches; do
        test_project "$sketch"
    done
    
    # Print summary
    print_summary
    local exit_code=$?
    
    exit $exit_code
}

# Run main function
main "$@"
