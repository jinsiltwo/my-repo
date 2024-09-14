package main

import "testing" # 테스트

func TestEvenOrOdd(t *testing.T) {
  result := EvenOrOdd(10)
  if result != "even" {
    t.Errorf("expected: even, actual: %s", result)
  }
}
