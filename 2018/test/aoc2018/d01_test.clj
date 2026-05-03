(ns aoc2018.d01-test
  (:require [clojure.test :refer [deftest is]]
            [aoc2018.d01 :as d]))

(def example1 "+1\n-2\n+3\n+1")
(def example2 "+1\n+1\n+1")
(def example3 "+1\n+1\n-2")
(def example4 "-1\n-2\n-3")
(def example5 "+1\n-1")
(def example6 "+3\n+3\n+4\n-2\n-4")
(def example7 "-6\n+3\n+8\n+5\n-6")
(def example8 "+7\n+7\n-2\n-7\n-4")

(deftest part1-test1
  (is (= 3 (d/part1 example1))))

(deftest part1-test2
  (is (= 3 (d/part1 example2))))

(deftest part1-test3
  (is (= 0 (d/part1 example3))))

(deftest part1-test4
  (is (= -6 (d/part1 example4))))

(deftest part2-test1
  (is (= 2 (d/part2 example1))))

(deftest part2-test1
  (is (= 2 (d/part2 example1))))

(deftest part2-test2
  (is (= 0 (d/part2 example5))))

(deftest part2-test3
  (is (= 10 (d/part2 example6))))

(deftest part2-test4
  (is (= 5 (d/part2 example7))))

(deftest part2-test5
  (is (= 14 (d/part2 example8))))