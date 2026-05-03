(ns aoc2018.d04
  (:require [clojure.string :as str]))

(defn parse [input]
  (->> (str/split-lines (str/trim input))
       sort))

(defn sleep-minutes [events]
  (loop [remaining events
         guard     nil
         slept-at  nil
         acc       {}]
    (if (empty? remaining)
      acc
      (let [line  (first remaining)
            [_ min] (map parse-long (re-seq #"\d+" (subs line 12 17)))]
        (cond
          (str/includes? line "Guard")
          (let [[id] (map parse-long (re-seq #"\d+" (subs line 19)))]
            (recur (rest remaining) id nil acc))

          (str/includes? line "falls")
          (recur (rest remaining) guard min acc)

          (str/includes? line "wakes")
          (recur (rest remaining) guard nil
                 (update acc guard into (range slept-at min))))))))

(defn part1 [input]
  (let [minutes     (sleep-minutes (parse input))
        sleepiest   (key (apply max-key #(count (val %)) minutes))
        sleep-freq  (frequencies (get minutes sleepiest))
        best-minute (key (apply max-key val sleep-freq))]
    (* sleepiest best-minute)))

(defn part2 [input]
  (let [minutes  (sleep-minutes (parse input))
        by-freq  (into {} (for [[id mins] minutes
                                :when (seq mins)]
                            [id (apply max-key val (frequencies mins))]))
        [id [minute _]] (apply max-key #(val (val %)) by-freq)]
    (* id minute)))

(defn -main []
  (let [input (slurp "inputs/04.txt")]
    (println (part1 input))
    (println (part2 input))))
