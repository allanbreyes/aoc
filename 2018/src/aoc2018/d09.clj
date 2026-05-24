(ns aoc2018.d09
  (:import [java.util ArrayDeque]))

(defn parse [input]
  (mapv parse-long (re-seq #"\d+" input)))

(defn play [num-players last-marble]
  (let [circle      (doto (ArrayDeque.) (.add 0))
        scores      (long-array num-players)
        rotate-cw!  #(dotimes [_ %] (.addLast  circle (.removeFirst circle)))
        rotate-ccw! #(dotimes [_ %] (.addFirst circle (.removeLast  circle)))]
    (loop [marble 1]
      (when (<= marble last-marble)
        (if (zero? (mod marble 23))
          (let [p (mod (dec marble) num-players)]
            (rotate-ccw! 7)
            (aset scores p (+ (aget scores p) marble (.removeFirst circle))))
          (do
            (rotate-cw! 2)
            (.addFirst circle marble)))
        (recur (inc marble))))
    (apply max (seq scores))))

(defn part1 [input]
  (apply play (parse input)))

(defn part2 [input]
  (let [[num-players last-marble] (parse input)]
    (play num-players (* 100 last-marble))))

(defn -main []
  (let [input (slurp "inputs/09.txt")]
    (println (part1 input))
    (println (part2 input))))
