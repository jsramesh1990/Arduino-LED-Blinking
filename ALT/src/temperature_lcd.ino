#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);

int sensor = A0;

void setup() {
  lcd.init();
  lcd.backlight();
}

void loop() {
  int value = analogRead(sensor);
  float temp = (value * 4.88) / 10;
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temp);
  lcd.print(" C");
  delay(1000);
}
