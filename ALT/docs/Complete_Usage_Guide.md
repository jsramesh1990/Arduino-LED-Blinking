## Basic Workflow

# 1. Check dependencies
make dependencies

# 2. Build all projects
make all

# 3. Build specific project
make led_blink

# 4. Upload a project
make upload-led_blink

# 5. Monitor serial output
make monitor

# 6. Run tests
make test

# 7. Clean build files
make clean


##  Advanced Usage


# Change board type (e.g., to Arduino Mega)
make set-board BOARD=arduino:avr:mega

# Build with verbose output
make VERBOSE=1 all

# Build in release mode (optimized)
make BUILD_MODE=release all

# Upload to specific port
make upload-led_blink PORT=/dev/ttyUSB1

# Generate documentation
make docs

# List available boards
make list-boards

# Run comprehensive test suite
make test 2>&1 | tee test_results.txt


##  Make it executable


chmod +x build_all.sh
./build_all.sh


## Testing System


The Makefile includes a comprehensive testing system:

# Run all tests
make test

# Test results are saved to logs/test.log
tail -f logs/test.log

# Individual test output for each project
cat logs/build_led_blink.log
cat logs/build_traffic_light.log



