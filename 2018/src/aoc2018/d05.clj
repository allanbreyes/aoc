(ns aoc2018.d05
  (:require [clojure.string :as str]))

(defn parse [input]
  (str/trim input))

(defn reacts? [a b]
  (and (not= a b) (= (Character/toLowerCase a) (Character/toLowerCase b))))

(defn reduce-polymer [polymer]
  (reduce (fn [stack c]
            (if (and (seq stack) (reacts? (peek stack) c))
              (pop stack)
              (conj stack c)))
          []
          polymer))

(defn part1 [input]
  (count (reduce-polymer (parse input))))

(defn part2 [input]
  (let [polymer (parse input)]
    (apply min (for [c "abcdefghijklmnopqrstuvwxyz"]
                 (->> (remove #{c (Character/toUpperCase c)} polymer)
                      reduce-polymer
                      count)))))

(defn -main []
  (let [input (slurp "inputs/05.txt")]
    (println (part1 input))
    (println (part2 input))))
