/*
 * Servo Motor Control
 * Controls a servo motor with potentiometer
 * 
 * Components:
 * - Arduino Board
 * - Servo Motor (SG90)
 * - Potentiometer
 * - Jumper wires
 * 
 * Connections:
 * Servo VCC  -> 5V
 * Servo GND  -> GND
 * Servo SIG  -> Pin 9
 * Potentiometer -> A0
 */

#include <Servo.h>

// Pin Definitions
const int SERVO_PIN = 9;
const int POT_PIN = A0;

// Create Servo object
Servo myServo;

// Variables
int potValue = 0;
int angle = 0;
int lastAngle = -1;  // Initialize to impossible value

void setup() {
  // Attach servo to pin
  myServo.attach(SERVO_PIN);
  
  // Initialize serial
  Serial.begin(9600);
  
  // Move to initial position
  myServo.write(90);
  
  Serial.println("Servo Motor Control System");
  Serial.println("==========================");
  Serial.println("Rotate potentiometer to control servo");
  delay(1000);
}

void loop() {
  // Read potentiometer value (0-1023)
  potValue = analogRead(POT_PIN);
  
  // Map to servo angle (0-180 degrees)
  angle = map(potValue, 0, 1023, 0, 180);
  
  // Move servo only if angle changed
  if (angle != lastAngle) {
    myServo.write(angle);
    lastAngle = angle;
    
    // Print position
    Serial.print("Servo Position: ");
    Serial.print(angle);
    Serial.println(" degrees");
    
    // Visual feedback on serial plotter
    Serial.print("PotValue:");
    Serial.print(potValue);
    Serial.print(",Angle:");
    Serial.println(angle);
  }
  
  delay(20);  // Small delay for stability
}

// Sweep function for demonstration
void sweepServo() {
  Serial.println("Starting Sweep Pattern");
  
  for (int pos = 0; pos <= 180; pos += 1) {
    myServo.write(pos);
    delay(15);
  }
  
  for (int pos = 180; pos >= 0; pos -= 1) {
    myServo.write(pos);
    delay(15);
  }
  
  Serial.println("Sweep Complete");
}
