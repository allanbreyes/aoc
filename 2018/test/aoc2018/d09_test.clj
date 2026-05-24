(ns aoc2018.d09-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d09 :as d]))

(deftest part1-test
  (is (= 32    (d/play 9  25)))
  (is (= 8317  (d/play 10 1618)))
  (is (= 146373 (d/play 13 7999)))
  (is (= 2764  (d/play 17 1104)))
  (is (= 54718 (d/play 21 6111)))
  (is (= 37305 (d/play 30 5807))))
