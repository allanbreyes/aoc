(ns aoc2018.d02
  (:require [clojure.string :as str]))

(defn parse [input]
  (str/split-lines (str/trim input)))

(defn part1 [input]
  (let [counts (map frequencies (parse input))
        has-n? (fn [n freqs] (some #(= n %) (vals freqs)))]
    (* (count (filter #(has-n? 2 %) counts))
       (count (filter #(has-n? 3 %) counts)))))

(defn part2 [input]
  (let [lines (parse input)
        [a b] (first (for [a lines, b lines
                           :when (= 1 (count (filter false? (map = a b))))]
                       [a b]))]
    (str/join (map first (filter #(apply = %) (map vector a b))))))

(defn -main []
  (let [input (slurp "inputs/02.txt")]
    (println (part1 input))
    (println (part2 input))))
