# Arduino LED Blinking Project

Arduino Embedded Systems Development Suite

https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/Platform-Arduino-00979D.svg
https://img.shields.io/badge/Kernel-AVR%2520GCC-blue.svg
https://img.shields.io/badge/build-passing-brightgreen
https://img.shields.io/badge/version-2.0.0-orange

<div align="center">
https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/Platform-Arduino-00979D.svg
https://img.shields.io/badge/Kernel-AVR_GCC-blue.svg
https://img.shields.io/badge/Version-2.0.0-orange.svg
https://img.shields.io/badge/Build-Passing-brightgreen.svg

</div>

A simple and beginner-friendly project demonstrating how to blink an LED using an **Arduino UNO**.
This repository includes:
- Source code
- Wiring guide
- Diagrams
- Expandable project structure


---


## Features
- Simple LED blink example
- Beginner friendly repository
- Clean folder structure
- Expandable for bigger projects


---


##  Components Required
- Arduino UNO
- LED
- 220Ω Resistor
- Jumper Wires


---


##  Wiring Instructions
| LED Pin | Connects To |
|--------|--------------|
| Long Leg (+) | Resistor → Arduino Pin **13** |
| Short Leg (–) | **GND** |


---


##  File Locations
- Code → `src/led_blink.ino`
- Wiring Guide → `docs/wiring_guide.md`
- Schematics Folder → `schematics/`


---


##   Upload to Tinkercad
1. Open **Tinkercad → Circuits**
2. Select **Create New Circuit**
3. Add components and wire them as per guide
4. Upload code
5. Start simulation


---


##   Arduino Code
```cpp
void setup() {
pinMode(13, OUTPUT);
}


void loop() {
digitalWrite(13, HIGH);
delay(1000);
digitalWrite(13, LOW);
delay(1000);
}
