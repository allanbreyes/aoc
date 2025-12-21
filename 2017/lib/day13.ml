module M = struct
  type layer = int * int
  type t = layer list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = line |> String.split_on_char ':' in
        let depth = parts |> List.hd |> String.trim |> int_of_string in
        let range =
          parts |> List.tl |> List.hd |> String.trim |> int_of_string
        in
        (depth, range))

  let simulate ?(offset = 0) (data : t) =
    let rec loop acc offset data =
      match data with
      | [] -> acc
      | (depth, range) :: t ->
          let period = if range = 1 then 1 else (range - 1) * 2 in
          let caught = (offset + depth) mod period = 0 in
          let score = if caught then depth * range else 0 in
          loop (acc + score) offset t
    in
    loop 0 offset data

  let part1 data = data |> simulate |> string_of_int |> print_endline

  let part2 data =
    let initial_period =
      data |> List.hd |> snd |> fun range ->
      if range = 1 then 1 else (range - 1) * 2
    in
    let rec loop offset =
      if simulate ~offset data = 0 && offset mod initial_period != 0 then offset
      else loop (offset + 1)
    in
    loop 0 |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
0: 3
1: 2
4: 4
6: 4
|}

let%expect_test _ =
  run example;
  [%expect {|
    24
    10
  |}]
