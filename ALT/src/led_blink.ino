/*
 * Basic LED Blink
 * Blinks an LED on pin 13
 * 
 * Components:
 * - Arduino Board
 * - LED
 * - 220Ω Resistor
 * 
 * Created: 2024
 * Author: Arduino Projects Suite
 * Version: 1.0
 */

// Pin Definitions
const int LED_PIN = 13;  // Built-in LED pin

// Timing Variables
const int BLINK_DELAY = 1000;  // Delay in milliseconds

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  
  // Initialize LED pin as output
  pinMode(LED_PIN, OUTPUT);
  
  // Print startup message
  Serial.println("LED Blink Project Started");
  Serial.println("==========================");
}

void loop() {
  // Turn LED ON
  digitalWrite(LED_PIN, HIGH);
  Serial.println("LED: ON");
  
  // Wait for specified time
  delay(BLINK_DELAY);
  
  // Turn LED OFF
  digitalWrite(LED_PIN, LOW);
  Serial.println("LED: OFF");
  
  // Wait for specified time
  delay(BLINK_DELAY);
  
  // Additional pattern: Fast blink every 5 cycles
  static int cycleCount = 0;
  cycleCount++;
  
  if (cycleCount % 5 == 0) {
    Serial.println("Fast Blink Pattern!");
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_PIN, HIGH);
      delay(200);
      digitalWrite(LED_PIN, LOW);
      delay(200);
    }
  }
}
