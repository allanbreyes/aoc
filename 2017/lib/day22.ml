module M = struct
  type point = int * int
  type state = Infected | Weakened | Flagged

  module PointMap = Map.Make (struct
    type t = point

    let compare = compare
  end)

  type t = state PointMap.t

  let parse (input : string) : t =
    let lines = input |> String.trim |> String.split_on_char '\n' in
    let rows = List.length lines in
    let cols = match lines with [] -> 0 | hd :: _ -> String.length hd in
    lines
    |> List.mapi (fun i line ->
        String.to_seq line
        |> Seq.mapi (fun j c ->
            if c = '#' then Some (i - (rows / 2), j - (cols / 2)) else None)
        |> Seq.filter_map (fun x -> x)
        |> List.of_seq)
    |> List.concat
    |> List.fold_left (fun m p -> PointMap.add p Infected m) PointMap.empty

  let dirs = [| (-1, 0); (0, 1); (1, 0); (0, -1) |]
  let turn i d = (d + i) mod 4

  let burst ?(times = 1) ?(resistance = false) ?(pos = (0, 0)) ?(d = 0) nodes =
    let left = turn 3 in
    let right = turn 1 in
    let reverse = turn 2 in
    let move (i, j) d =
      let di, dj = dirs.(d) in
      (i + di, j + dj)
    in
    let rec loop n states p d acc =
      if n = 0 then acc
      else
        let state = PointMap.find_opt p states in
        let d', states', acc' =
          match (resistance, state) with
          | false, Some Infected -> (right d, PointMap.remove p states, acc)
          | false, None -> (left d, PointMap.add p Infected states, acc + 1)
          | true, None -> (left d, PointMap.add p Weakened states, acc)
          | true, Some Weakened -> (d, PointMap.add p Infected states, acc + 1)
          | true, Some Infected -> (right d, PointMap.add p Flagged states, acc)
          | true, Some Flagged -> (reverse d, PointMap.remove p states, acc)
          | _ -> failwith "unhandled state"
        in
        loop (n - 1) states' (move p d') d' acc'
    in
    loop times nodes pos d 0

  let part1 nodes =
    burst ~times:10000 ~resistance:false nodes |> string_of_int |> print_endline

  let part2 nodes =
    burst ~times:10000000 ~resistance:true nodes
    |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
..#
#..
...
|}

let%expect_test _ =
  run example;
  [%expect {|
    5587
    2511944
  |}]
