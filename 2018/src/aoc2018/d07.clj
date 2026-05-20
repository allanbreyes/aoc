(ns aoc2018.d07
  (:require [clojure.string :as str]))

(defn parse [input]
  (for [line (str/split-lines (str/trim input))]
    [(second (re-find #"Step (\w)" line))
     (second (re-find #"step (\w)" line))]))

(defn build-deps [edges]
  (let [all-steps (set (concat (map first edges) (map second edges)))]
    (reduce (fn [deps [before after]]
              (update deps after conj before))
            (zipmap all-steps (repeat #{}))
            edges)))

(defn topo-sort [deps]
  (loop [deps   deps
         result []]
    (if (empty? deps)
      (str/join result)
      (let [ready (first (sort (keep (fn [[step prereqs]]
                                       (when (empty? prereqs) step))
                                     deps)))]
        (recur (-> deps
                   (dissoc ready)
                   (update-vals #(disj % ready)))
               (conj result ready))))))

(defn part1 [input]
  (topo-sort (build-deps (parse input))))

(defn step-time [offset step]
  (+ offset (inc (- (int (first step)) (int \A)))))

(defn simulate [deps num-workers offset]
  (loop [deps    deps
         workers []
         time    0]
    (if (and (empty? deps) (empty? workers))
      time
      (let [in-progress (set (map first workers))
            available   (->> deps
                             (keep (fn [[step prereqs]] (when (empty? prereqs) step)))
                             (remove in-progress)
                             sort
                             (take (- num-workers (count workers))))
            workers     (into workers (map #(vector % (+ time (step-time offset %))) available))
            next-time   (apply min (map second workers))
            finished    (->> workers (filter #(= next-time (second %))) (map first) set)
            workers     (filterv #(not (finished (first %))) workers)
            deps        (-> (apply dissoc deps finished)
                            (update-vals #(reduce disj % finished)))]
        (recur deps workers next-time)))))

(defn part2 [input & [num-workers offset]]
  (simulate (build-deps (parse input))
            (or num-workers 5)
            (or offset 60)))

(defn -main []
  (let [input (slurp "inputs/07.txt")]
    (println (part1 input))
    (println (part2 input))))
