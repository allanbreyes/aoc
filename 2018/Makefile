DAY ?= 00

run:
	clojure -M -m aoc2018.d$(DAY)

test:
	clojure -M:test

new:
	@cp src/aoc2018/d00.clj src/aoc2018/d$(DAY).clj
	@sed -i 's/d00/d$(DAY)/g' src/aoc2018/d$(DAY).clj
	@cp test/aoc2018/d00_test.clj test/aoc2018/d$(DAY)_test.clj
	@sed -i 's/d00/d$(DAY)/g' test/aoc2018/d$(DAY)_test.clj
	@sed -i 's/00\.txt/$(DAY).txt/g' test/aoc2018/d$(DAY)_test.clj
	@touch inputs/$(DAY).txt
	@echo "Created day $(DAY)"

pull:
	curl -s "https://adventofcode.com/2018/day/$$(echo $(DAY) | sed 's/^0*//')/input" \
	  -H "Cookie: session=$$(kv get aoc)" \
	  | tee inputs/$(DAY).txt

.PHONY: run test new pull
