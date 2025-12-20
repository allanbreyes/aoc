module M = struct
  type t = (string * int * string list) list

  module StringMap = Map.Make (String)
  module StringSet = Set.Make (String)

  exception Imbalance of int

  let parse (input : string) : t =
    input |> String.split_on_char '\n'
    |> List.map (String.split_on_char ' ')
    |> List.filter_map (function
      | name :: w :: "->" :: rest ->
          let weight = Scanf.sscanf w "(%d)" (fun x -> x) in
          let children =
            rest |> String.concat " " |> String.split_on_char ','
            |> List.filter_map (fun s ->
                let s = String.trim s in
                if s = "" then None else Some s)
          in
          Some (name, weight, children)
      | name :: w :: _ ->
          let weight = Scanf.sscanf w "(%d)" (fun x -> x) in
          Some (name, weight, [])
      | _ -> None)

  let build data =
    let rec build_map acc rest =
      match rest with
      | [] -> acc
      | (name, weight, children) :: rest ->
          let acc = StringMap.add name (weight, children) acc in
          build_map acc rest
    in
    build_map StringMap.empty data

  let find_root data =
    let nodes =
      List.fold_left
        (fun acc (name, _, _) -> StringSet.add name acc)
        StringSet.empty data
    in
    let children =
      List.fold_left
        (fun acc (_, _, children) ->
          List.fold_left (fun acc child -> StringSet.add child acc) acc children)
        StringSet.empty data
    in
    match StringSet.diff nodes children |> StringSet.elements with
    | [ root ] -> Some root
    | _ -> None

  let find_imbalance map root =
    let rec diff node =
      let weight, children = StringMap.find node map in
      let diffs = List.map diff children in
      let sums =
        diffs |> List.map (fun (w, c) -> (w + c, w)) |> List.sort compare
      in
      match (sums, List.rev sums) with
      | [], [] -> (weight, 0)
      | (x, _) :: _, (x', _) :: _ when x = x' -> (weight, x * List.length sums)
      | (x, _) :: (x2, _) :: _, (y, w) :: _ when x = x2 ->
          let diffv = x - y in
          raise (Imbalance (w + diffv))
      | (y, w) :: _, (x, _) :: (x2, _) :: _ when x = x2 ->
          let diffv = x - y in
          raise (Imbalance (w + diffv))
      | _ -> (weight, 0)
    in
    try
      let w, _ = diff root in
      w
    with Imbalance v -> v

  let part1 data = find_root data |> Option.iter print_endline

  let part2 data =
    let map = build data in
    find_root data
    |> Option.iter (fun root ->
        find_imbalance map root |> string_of_int |> print_endline)
end

include M
include Day.Make (M)

let example =
  {|
pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)
|}

let%expect_test _ =
  run example;
  [%expect {|
    tknk
    60
  |}]
