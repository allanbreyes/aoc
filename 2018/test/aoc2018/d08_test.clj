(ns aoc2018.d08-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d08 :as d]))

(def example "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")

(deftest part1-test
  (is (= 138 (d/part1 example))))

(deftest part2-test
  (is (= 66 (d/part2 example))))
