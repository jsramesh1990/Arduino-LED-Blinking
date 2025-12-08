/*
 * Ultrasonic Distance Measurement
 * Measures distance using HC-SR04 sensor
 * 
 * Components:
 * - Arduino Board
 * - HC-SR04 Ultrasonic Sensor
 * - LED (optional)
 * 
 * Connections:
 * HC-SR04 VCC  -> 5V
 * HC-SR04 GND  -> GND
 * HC-SR04 TRIG -> Pin 9
 * HC-SR04 ECHO -> Pin 10
 */

// Pin Definitions
const int TRIG_PIN = 9;
const int ECHO_PIN = 10;
const int LED_PIN = 13;  // Optional indicator LED

// Constants
const float SOUND_SPEED = 0.0343;  // cm/μs at 20°C
const int MAX_DISTANCE = 400;      // Maximum measurable distance (cm)
const int MIN_DISTANCE = 2;        // Minimum measurable distance (cm)

// Variables
float distance = 0;
float duration = 0;

void setup() {
  // Initialize pins
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  
  // Initialize serial
  Serial.begin(9600);
  
  Serial.println("Ultrasonic Distance Measurement");
  Serial.println("===============================");
}

void loop() {
  // Clear trigger pin
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  
  // Set trigger pin HIGH for 10μs
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  // Read echo pin duration
  duration = pulseIn(ECHO_PIN, HIGH);
  
  // Calculate distance
  distance = (duration * SOUND_SPEED) / 2;
  
  // Validate distance reading
  if (distance >= MAX_DISTANCE || distance <= MIN_DISTANCE) {
    Serial.println("Out of range");
    digitalWrite(LED_PIN, HIGH);  // Error indicator
  } else {
    // Print distance
    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.println(" cm");
    
    // Blink LED based on distance
    blinkLEDBasedOnDistance(distance);
  }
  
  delay(500);  // Wait before next measurement
}

void blinkLEDBasedOnDistance(float dist) {
  // Blink pattern changes based on distance
  digitalWrite(LED_PIN, HIGH);
  
  if (dist < 10) {
    delay(100);  // Fast blink for close objects
  } else if (dist < 50) {
    delay(300);  // Medium blink
  } else {
    delay(700);  // Slow blink for far objects
  }
  
  digitalWrite(LED_PIN, LOW);
  delay(100);
}
