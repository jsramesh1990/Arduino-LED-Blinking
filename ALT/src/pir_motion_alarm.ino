int pir = 7;
int buzzer = 6;

void setup() {
  pinMode(pir, INPUT);
  pinMode(buzzer, OUTPUT);
}

void loop() {
  if (digitalRead(pir) == HIGH) {
    digitalWrite(buzzer, HIGH);
    delay(500);
  } else {
    digitalWrite(buzzer, LOW);
  }
}
