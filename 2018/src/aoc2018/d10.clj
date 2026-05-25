(ns aoc2018.d10
  (:require [clojure.string :as str]))

(defn parse [input]
  (for [line (str/split-lines (str/trim input))]
    (let [[x y vx vy] (map parse-long (re-seq #"-?\d+" line))]
      [x y vx vy])))

(defn positions-at [points t]
  (map (fn [[x y vx vy]] [(+ x (* vx t)) (+ y (* vy t))]) points))

(defn height [pts]
  (let [ys (map second pts)]
    (- (apply max ys) (apply min ys))))

(defn find-time [points]
  (loop [t 0
         h (height (positions-at points 0))]
    (let [h' (height (positions-at points (inc t)))]
      (if (< h' h)
        (recur (inc t) h')
        t))))

(defn render [pts]
  (let [xs   (map first pts)
        ys   (map second pts)
        x0   (apply min xs)
        x1   (apply max xs)
        y0   (apply min ys)
        y1   (apply max ys)
        grid (set pts)]
    (str/join "\n"
              (for [y (range y0 (inc y1))]
                (str/join (for [x (range x0 (inc x1))]
                            (if (grid [x y]) "#" ".")))))))

(defn part1 [input]
  (let [points (parse input)
        t      (find-time points)]
    (render (positions-at points t))))

(defn part2 [input]
  (find-time (parse input)))

(defn -main []
  (let [input (slurp "inputs/10.txt")]
    (println (part1 input))
    (println (part2 input))))
