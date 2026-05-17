(ns aoc2018.d05-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d05 :as d]))

(def example "dabAcCaCBAcCcaDA")

(deftest part1-test
  (is (= 10 (d/part1 example))))

(deftest part2-test
  (is (= 4 (d/part2 example))))
