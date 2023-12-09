package main

import (
	"fmt"
	"os"
)

func New(day int) {
	os.Mkdir(fmt.Sprintf("d%02d", day), 0755)
	file, _ := os.Create(fmt.Sprintf("d%02d/d%02d.go", day, day))
	defer file.Close()
	fmt.Fprintf(file, `package d%02d

import "strings"

func SolvePart1(input string) (ans int) {
	return
}

func SolvePart2(input string) (ans int) {
	return
}

func parse(input string) []string {
	return strings.Split(input, "\n")
}
`, day)

	test, _ := os.Create(fmt.Sprintf("d%02d/d%02d_test.go", day, day))
	defer test.Close()
	fmt.Fprintf(test, `package d%02d

import (
	"testing"
)

var input = "input"

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 0
	if got != want {
		t.Errorf("got %%d, want %%d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 0
	if got != want {
		t.Errorf("got %%d, want %%d", got, want)
	}
}
`, day)
}
