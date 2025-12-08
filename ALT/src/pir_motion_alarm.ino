/*
 * PIR Motion Alarm System
 * Detects motion and triggers alarm
 * 
 * Components:
 * - Arduino Board
 * - PIR Motion Sensor
 * - LED
 * - Buzzer
 * - 220Ω Resistor (for LED)
 * 
 * Connections:
 * PIR OUT -> Pin 2
 * LED     -> Pin 13
 * Buzzer  -> Pin 8
 */

// Pin Definitions
const int PIR_PIN = 2;     // PIR sensor output
const int LED_PIN = 13;    // Status LED
const int BUZZER_PIN = 8;  // Buzzer

// Variables
int motionState = LOW;     // No motion detected initially
int lastMotionState = LOW;

// Timing
unsigned long lastMotionTime = 0;
const unsigned long MOTION_TIMEOUT = 10000;  // 10 seconds

void setup() {
  // Initialize pins
  pinMode(PIR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Initialize serial
  Serial.begin(9600);
  
  // Calibration message
  Serial.println("PIR Motion Alarm System");
  Serial.println("Calibrating sensor...");
  delay(10000);  // Allow PIR to calibrate
  Serial.println("System Ready!");
  Serial.println("======================");
}

void loop() {
  // Read PIR sensor state
  motionState = digitalRead(PIR_PIN);
  
  // Check if motion state changed
  if (motionState != lastMotionState) {
    if (motionState == HIGH) {
      // Motion detected
      Serial.println("Motion Detected!");
      lastMotionTime = millis();
      triggerAlarm();
    } else {
      // Motion stopped
      Serial.println("Motion Ended");
      stopAlarm();
    }
    lastMotionState = motionState;
  }
  
  // Auto-reset alarm after timeout
  if (motionState == HIGH && (millis() - lastMotionTime > MOTION_TIMEOUT)) {
    Serial.println("Motion Timeout - Resetting");
    stopAlarm();
    motionState = LOW;
    lastMotionState = LOW;
  }
  
  delay(50);  // Small delay for stability
}

void triggerAlarm() {
  // Flash LED and sound buzzer
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZER_PIN, 1000, 200);  // 1kHz tone for 200ms
}

void stopAlarm() {
  // Stop alarm
  digitalWrite(LED_PIN, LOW);
  noTone(BUZZER_PIN);
}
