/*
 * Configuration File
 * Common settings for all projects
 */

#ifndef CONFIG_H
#define CONFIG_H

// Debug Settings
#define DEBUG_MODE true
#define SERIAL_BAUD 9600

// Pin Assignments (Common)
#define BUILTIN_LED 13
#define BUZZER_PIN 8

// Timing Constants
#define DEBOUNCE_DELAY 50
#define DEFAULT_TIMEOUT 10000

// Sensor Thresholds
#define TEMP_HIGH_THRESHOLD 30.0
#define TEMP_LOW_THRESHOLD 10.0
#define DISTANCE_NEAR 10.0
#define DISTANCE_FAR 100.0

#endif
