(ns aoc2018.d00
  (:require [clojure.string :as str]))

(defn parse [input]
  (str/split-lines (str/trim input)))

(defn part1 [input]
  (let [lines (parse input)]
    0))

(defn part2 [input]
  (let [lines (parse input)]
    0))

(defn -main []
  (let [input (slurp "inputs/00.txt")]
    (println (part1 input))
    (println (part2 input))))
