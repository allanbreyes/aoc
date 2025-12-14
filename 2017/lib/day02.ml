open Containers

module M = struct
  type t = int list list

  let parse input =
    input |> String.split_on_char '\n'
    |> List.filter_map (fun line ->
        let line = String.trim line in
        if CCString.is_empty line then None
        else
          Some
            (line
            |> Str.split (Str.regexp "[ \t]+")
            |> List.filter (fun s -> not (CCString.is_empty s))
            |> List.map int_of_string))

  let sum row =
    let min = List.fold_left min max_int row in
    let max = List.fold_left max min_int row in
    max - min

  let divisible a b = a mod b = 0 || b mod a = 0

  let rec divide row =
    match row with
    | [] -> invalid_arg "no divisible pair"
    | h :: t -> (
        match List.find_opt (divisible h) t with
        | Some x -> if h mod x = 0 then h / x else x / h
        | None -> divide t)

  let part1 data =
    let ans = List.fold_left (fun acc row -> acc + sum row) 0 data in
    Printf.printf "%d\n" ans

  let part2 data =
    let ans = List.fold_left (fun acc row -> acc + divide row) 0 data in
    Printf.printf "%d\n" ans
end

include M
include Day.Make (M)

let example1 = {|
5 1 9 5
7 5 3
2 4 6 8
|}

let example2 = {|
5 9 2 8
9 4 7 3
3 8 6 5
|}

let%expect_test _ =
  run ~only_part1:true example1;
  [%expect {|
    18
  |}]

let%expect_test _ =
  run ~only_part2:true example2;
  [%expect {|
    9
  |}]
