(ns aoc2018.d03
  (:require [clojure.string :as str]))

(defn parse [input]
  (for [line (str/split-lines (str/trim input))]
    (let [[id l t w h] (map parse-long (re-seq #"\d+" line))]
      {:id id :l l :t t :w w :h h})))

(defn claim-coords [{:keys [l t w h]}]
  (for [x (range l (+ l w))
        y (range t (+ t h))]
    [x y]))

(defn part1 [input]
  (->> (parse input)
       (mapcat claim-coords)
       frequencies
       (filter #(>= (val %) 2))
       count))

(defn intact [claims]
  (let [freq (frequencies (mapcat claim-coords claims))]
    (filter #(every? (fn [c] (= 1 (freq c))) (claim-coords %)) claims)))

(defn part2 [input]
  (->> (parse input)
       intact
       first
       :id))

(defn -main []
  (let [input (slurp "inputs/03.txt")]
    (println (part1 input))
    (println (part2 input))))
