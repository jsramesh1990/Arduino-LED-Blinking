/*
 * Temperature Display on LCD
 * Reads temperature from LM35 and displays on LCD
 * 
 * Components:
 * - Arduino Board
 * - LM35 Temperature Sensor
 * - 16x2 LCD Display
 * - Potentiometer (for LCD contrast)
 * - 220Ω Resistor
 * 
 * Connections:
 * LM35 VCC -> 5V
 * LM35 OUT -> A0
 * LM35 GND -> GND
 * 
 * LCD RS -> Pin 12
 * LCD EN -> Pin 11
 * LCD D4 -> Pin 5
 * LCD D5 -> Pin 4
 * LCD D6 -> Pin 3
 * LCD D7 -> Pin 2
 * LCD VCC -> 5V
 * LCD GND -> GND
 */

#include <LiquidCrystal.h>

// LCD Pin Definitions
const int RS = 12, EN = 11, D4 = 5, D5 = 4, D6 = 3, D7 = 2;

// Temperature Sensor Pin
const int TEMP_SENSOR_PIN = A0;

// Initialize LCD
LiquidCrystal lcd(RS, EN, D4, D5, D6, D7);

// Variables
float temperatureC = 0;
float temperatureF = 0;
unsigned long lastUpdate = 0;
const unsigned long UPDATE_INTERVAL = 2000;  // Update every 2 seconds

void setup() {
  // Initialize LCD
  lcd.begin(16, 2);
  
  // Initialize serial
  Serial.begin(9600);
  
  // Print welcome message
  lcd.clear();
  lcd.print("Temp Monitor");
  lcd.setCursor(0, 1);
  lcd.print("Initializing...");
  
  Serial.println("Temperature Monitoring System");
  Serial.println("=============================");
  
  delay(2000);
}

void loop() {
  // Update temperature at regular intervals
  if (millis() - lastUpdate >= UPDATE_INTERVAL) {
    readTemperature();
    displayTemperature();
    lastUpdate = millis();
  }
  
  // Check for serial commands
  if (Serial.available()) {
    char command = Serial.read();
    if (command == 'r') {
      readTemperature();
      Serial.print("Current Temp: ");
      Serial.print(temperatureC);
      Serial.println(" °C");
    }
  }
}

void readTemperature() {
  // Read analog value
  int sensorValue = analogRead(TEMP_SENSOR_PIN);
  
  // Convert to voltage (assuming 5V reference)
  float voltage = sensorValue * (5.0 / 1023.0);
  
  // Convert to Celsius (LM35: 10mV per °C)
  temperatureC = voltage * 100;
  
  // Convert to Fahrenheit
  temperatureF = (temperatureC * 9.0 / 5.0) + 32.0;
}

void displayTemperature() {
  // Display on LCD
  lcd.clear();
  lcd.print("Temp: ");
  lcd.print(temperatureC, 1);
  lcd.print((char)223);  // Degree symbol
  lcd.print("C");
  
  lcd.setCursor(0, 1);
  lcd.print("     ");
  lcd.print(temperatureF, 1);
  lcd.print((char)223);
  lcd.print("F");
  
  // Display on Serial Monitor
  Serial.print("Temperature: ");
  Serial.print(temperatureC, 1);
  Serial.print(" °C | ");
  Serial.print(temperatureF, 1);
  Serial.println(" °F");
  
  // Warning if temperature is high
  if (temperatureC > 30.0) {
    Serial.println("WARNING: High Temperature!");
    lcd.setCursor(15, 0);
    lcd.print("!");
  }
}
