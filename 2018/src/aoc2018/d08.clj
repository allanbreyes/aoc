(ns aoc2018.d08
  (:require [clojure.string :as str]))

(defn parse [input]
  (map parse-long (str/split (str/trim input) #" ")))

(defn parse-node [[n-children n-meta & nums]]
  (let [[children remaining] (reduce (fn [[children remaining] _]
                                       (let [[child remaining] (parse-node remaining)]
                                         [(conj children child) remaining]))
                                     [[] nums]
                                     (range n-children))
        metadata (take n-meta remaining)]
    [{:children children :metadata metadata} (drop n-meta remaining)]))

(defn sum-metadata [{:keys [children metadata]}]
  (+ (reduce + metadata)
     (reduce + (map sum-metadata children))))

(defn node-value [{:keys [children metadata]}]
  (if (empty? children)
    (reduce + metadata)
    (->> (keep #(nth children (dec %) nil) metadata)
         (map node-value)
         (reduce + 0))))

(defn tree [input]
  (first (parse-node (parse input))))

(defn part1 [input]
  (sum-metadata (tree input)))

(defn part2 [input]
  (node-value (tree input)))

(defn -main []
  (let [input (slurp "inputs/08.txt")]
    (println (part1 input))
    (println (part2 input))))
