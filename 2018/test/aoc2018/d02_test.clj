(ns aoc2018.d02-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d02 :as d]))

(def example "abcdef\nbababc\nabbcde\nabcccd\naabcdd\nabcdee\nababab")

(deftest part1-test
  (is (= 12 (d/part1 example))))

(def example2 "abcde\nfghij\nklmno\npqrst\nfguij\naxcye\nwvxyz")

(deftest part2-test
  (is (= "fgij" (d/part2 example2))))
