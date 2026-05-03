(ns aoc2018.d00-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d00 :as d]))

(def example "foobarbaz")

(deftest part1-test
  (is (= 0 (d/part1 example))))

(deftest part2-test
  (is (= 0 (d/part2 example))))
