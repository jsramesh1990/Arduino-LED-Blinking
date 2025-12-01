#include <Servo.h>

Servo s;
int pos = 0;

void setup() {
  s.attach(9);
}

void loop() {
  for (pos = 0; pos <= 180; pos++) {
    s.write(pos);
    delay(10);
  }
  for (pos = 180; pos >= 0; pos--) {
    s.write(pos);
    delay(10);
  }
}
