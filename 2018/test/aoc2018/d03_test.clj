(ns aoc2018.d03-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d03 :as d]))

(def example "#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 5,5: 2x2")

(deftest part1-test
  (is (= 4 (d/part1 example))))

(deftest part2-test
  (is (= 3 (d/part2 example))))
