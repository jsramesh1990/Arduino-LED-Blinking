/*
 * Helper Functions Library
 */

#ifndef HELPERS_H
#define HELPERS_H

#include <Arduino.h>

// LED Control Functions
void blinkLED(int pin, int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(pin, HIGH);
    delay(delayMs);
    digitalWrite(pin, LOW);
    delay(delayMs);
  }
}

void fadeLED(int pin, int duration) {
  for (int brightness = 0; brightness <= 255; brightness++) {
    analogWrite(pin, brightness);
    delay(duration / 255);
  }
  for (int brightness = 255; brightness >= 0; brightness--) {
    analogWrite(pin, brightness);
    delay(duration / 255);
  }
}

// Serial Debug Functions
void debugPrint(String message) {
  #ifdef DEBUG_MODE
    Serial.println("[DEBUG] " + message);
  #endif
}

void errorPrint(String message) {
  Serial.println("[ERROR] " + message);
}

// Validation Functions
bool isValidTemperature(float temp) {
  return (temp >= -40.0 && temp <= 125.0);
}

bool isValidDistance(float distance) {
  return (distance >= 2.0 && distance <= 400.0);
}

// Math Utilities
float celsiusToFahrenheit(float celsius) {
  return (celsius * 9.0 / 5.0) + 32.0;
}

float fahrenheitToCelsius(float fahrenheit) {
  return (fahrenheit - 32.0) * 5.0 / 9.0;
}

#endif
