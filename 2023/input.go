package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

func LoadInput(day int, actual bool) string {
	folder := "examples"
	if actual {
		folder = "inputs"
	}
	filename := fmt.Sprintf("%s/%02d.txt", folder, day)
	file, err := os.Open(filename)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	bytes, err := ioutil.ReadAll(file)
	if err != nil {
		log.Fatal(err)
	}

	return string(bytes)
}
