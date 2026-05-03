(ns aoc2018.d01
  (:require [clojure.string :as str]))

(defn parse [input]
  (->> (str/split-lines (str/trim input))
       (map #(Integer/parseInt %))))

(defn part1 [input]
  (reduce + (parse input)))

(defn part2 [input]
  (reduce (fn [[curr seen] change]
            (let [next (+ curr change)]
              (if (seen next)
                (reduced next)
                [next (conj seen next)])))
          [0 #{0}]
          (cycle (parse input))))

(defn -main []
  (let [input (slurp "inputs/01.txt")]
    (println (part1 input))
    (println (part2 input))))
