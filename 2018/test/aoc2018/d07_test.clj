(ns aoc2018.d07-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d07 :as d]))

(def example
  "Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.")

(deftest part1-test
  (is (= "CABDFE" (d/part1 example))))

(deftest part2-test
  (is (= 15 (d/part2 example 2 0))))
