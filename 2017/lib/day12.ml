module M = struct
  type connection = int * int list
  type t = connection list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = Str.split (Str.regexp " <-> ") line in
        let program = int_of_string (List.hd parts) in
        let neighbors =
          parts |> List.tl |> List.hd
          |> Str.split (Str.regexp ", ")
          |> List.map int_of_string
        in
        (program, neighbors))

  let max_id_of (data : t) =
    List.fold_left
      (fun acc (program, neighbors) ->
        let max_neighbor = List.fold_left max (-1) neighbors in
        max acc (max program max_neighbor))
      (-1) data

  let build_dsu (data : t) =
    let max_id = max_id_of data in
    let ds = Utils.DSU.make_set (max 0 (max_id + 1)) in
    List.iter
      (fun (program, neighbors) ->
        List.iter
          (fun neighbor -> Utils.DSU.union ds program neighbor)
          neighbors)
      data;
    (ds, max_id)

  let part1 data =
    let ds, max_id = build_dsu data in
    let root0 = Utils.DSU.find ds 0 in
    let rec count i acc =
      if i > max_id then acc
      else count (i + 1) (acc + if Utils.DSU.find ds i = root0 then 1 else 0)
    in
    let size = if max_id < 0 then 0 else count 0 0 in
    size |> string_of_int |> print_endline

  let part2 data =
    let ds, max_id = build_dsu data in
    let rec count_roots i acc =
      if i > max_id then acc
      else count_roots (i + 1) (acc + if Utils.DSU.find ds i = i then 1 else 0)
    in
    let groups = if max_id < 0 then 0 else count_roots 0 0 in
    groups |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example =
  {|
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5
|}

let%expect_test _ =
  run example;
  [%expect {|
    6
    2
  |}]
