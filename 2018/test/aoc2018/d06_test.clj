(ns aoc2018.d06-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d06 :as d]))

(def example "1, 1\n1, 6\n8, 3\n3, 4\n5, 5\n8, 9")

(deftest part1-test
  (is (= 17 (d/part1 example))))

(deftest part2-test
  (is (= 16 (d/part2 example 32))))
