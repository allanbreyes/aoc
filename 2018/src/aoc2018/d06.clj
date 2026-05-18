(ns aoc2018.d06
  (:require [clojure.string :as str]))

(defn parse [input]
  (for [line (str/split-lines (str/trim input))]
    (mapv parse-long (str/split line #", "))))

(defn manhattan [[x1 y1] [x2 y2]]
  (+ (Math/abs (- x1 x2)) (Math/abs (- y1 y2))))

(defn closest [coords point]
  (loop [cs       coords
         min-dist Long/MAX_VALUE
         winner   nil
         tied?    false]
    (if (empty? cs)
      (when-not tied? winner)
      (let [d (manhattan point (first cs))]
        (cond
          (< d min-dist) (recur (rest cs) d (first cs) false)
          (= d min-dist) (recur (rest cs) d winner true)
          :else          (recur (rest cs) min-dist winner tied?))))))

(defn part1 [input]
  (let [coords   (vec (parse input))
        xs       (map first coords)
        ys       (map second coords)
        [x0 x1] [(apply min xs) (apply max xs)]
        [y0 y1] [(apply min ys) (apply max ys)]
        border?  (fn [[x y]] (or (= x x0) (= x x1) (= y y0) (= y y1)))
        points   (for [x (range x0 (inc x1))
                       y (range y0 (inc y1))]
                   [[x y] (closest coords [x y])])
        infinite (->> points
                      (filter (comp border? first))
                      (map second)
                      (remove nil?)
                      set)]
    (->> points
         (map second)
         (remove nil?)
         (remove infinite)
         frequencies
         vals
         (apply max))))

(defn part2 [input & [threshold]]
  (let [coords   (vec (parse input))
        xs       (map first coords)
        ys       (map second coords)
        [x0 x1] [(apply min xs) (apply max xs)]
        [y0 y1] [(apply min ys) (apply max ys)]
        limit    (or threshold 10000)]
    (->> (for [x (range x0 (inc x1))
               y (range y0 (inc y1))]
           (reduce + (map #(manhattan [x y] %) coords)))
         (filter #(< % limit))
         count)))

(defn -main []
  (let [input (slurp "inputs/06.txt")]
    (println (part1 input))
    (println (part2 input))))
