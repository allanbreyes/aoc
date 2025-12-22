module M = struct
  type t = int
  type node = { value : int; mutable next : node }

  let parse (input : string) : t = input |> String.trim |> int_of_string

  let insert before value =
    let node = { value; next = before.next } in
    before.next <- node;
    node

  let rec spin current left =
    if left = 0 then current else spin current.next (left - 1)

  let simulate ?(max = 2017) n =
    let rec node = { value = 0; next = node } in
    let rec loop ?(i = 0) ~max current =
      if i = max then current.next
      else begin
        let current' = spin current n in
        let inserted = insert current' (i + 1) in
        loop ~i:(i + 1) ~max inserted
      end
    in
    loop ~max node |> fun node' -> node'.value

  let part1 n = simulate n |> string_of_int |> print_endline

  let part2 steps =
    let rec count ?(len = 1) ?(at = 0) ?(n = 50_000_000) last =
      if n = 0 then last
      else
        let ins = 1 + ((at + steps) mod len) in
        let last' = if ins = 1 then len else last in
        count ~len:(len + 1) ~at:ins ~n:(n - 1) last'
    in
    count 0 |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {| 3 |}

let%expect_test _ =
  run example;
  [%expect {|
    638
    1222153
  |}]
