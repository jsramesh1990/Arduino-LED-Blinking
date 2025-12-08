##  Install Required Dependencies

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    arduino-cli \
    gcc-avr \
    avr-libc \
    avrdude \
    make \
    screen \
    python3 \
    python3-pip \
    doxygen \
    graphviz

# Install Python packages
pip3 install pyserial colorama

# macOS
brew install arduino-cli
brew install avr-gcc
brew install avrdude
brew install make
brew install screen
brew install doxygen
brew install graphviz

# Install Python packages
pip3 install pyserial colorama

# Windows (using Chocolatey)
choco install arduino-cli
choco install avr-gcc
choco install avrdude
choco install make
choco install doxygen.install
choco install graphviz


## Setup Arduino CLI


# Initialize Arduino CLI
arduino-cli config init

# Update core index
arduino-cli core update-index

# Install Arduino AVR core
arduino-cli core install arduino:avr

# Install required libraries
arduino-cli lib install Servo
arduino-cli lib install LiquidCrystal


##   Create the Project Structure


# Create the directory structure
mkdir -p Arduino-LED-Blinking-main/{scripts,config,build,logs,extras}
mkdir -p Arduino-LED-Blinking-main/ALT/{docs,src,schematics}

# Copy all the files from above to their respective locations
# (Create the files with the content provided above)

# Make scripts executable
chmod +x Arduino-LED-Blinking-main/scripts/*.sh

# Initialize the project
cd Arduino-LED-Blinking-main
make setup



