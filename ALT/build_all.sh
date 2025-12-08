#!/bin/bash
# build_all.sh - Comprehensive build script

echo "=== Arduino Project Build System ==="
echo ""

# Check dependencies
echo "1. Checking dependencies..."
make dependencies
if [ $? -ne 0 ]; then
    echo "Dependency check failed. Exiting."
    exit 1
fi

# Clean previous builds
echo "2. Cleaning previous builds..."
make clean

# Build all projects
echo "3. Building all projects..."
make all
if [ $? -ne 0 ]; then
    echo "Build failed. Check logs/build.log"
    exit 1
fi

# Run tests
echo "4. Running tests..."
make test
if [ $? -ne 0 ]; then
    echo "Tests failed. Check logs/test.log"
    exit 1
fi

# Generate documentation
echo "5. Generating documentation..."
make docs

echo ""
echo "=== Build Complete ==="
echo "Projects built:"
ls -la build/*/*.hex 2>/dev/null || echo "No build files found"
echo ""
echo "Next steps:"
echo "  make upload-<project_name>  # Upload specific project"
echo "  make monitor                # Open serial monitor"
echo "  make help                   # Show all commands"
