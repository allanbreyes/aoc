module M = struct
  type t = string list
  type position = int * int * int

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char ','

  let move (x, y, z) direction =
    match direction with
    | "n" -> (x, y + 1, z - 1)
    | "ne" -> (x + 1, y, z - 1)
    | "se" -> (x + 1, y - 1, z)
    | "s" -> (x, y - 1, z + 1)
    | "sw" -> (x - 1, y, z + 1)
    | "nw" -> (x - 1, y + 1, z)
    | _ -> failwith "unhandled direction"

  let solve data =
    let dist (x, y, z) = [ abs x; abs y; abs z ] |> List.fold_left max 0 in
    let furthest = ref 0 in
    let rec loop (x, y, z) = function
      | [] -> (x, y, z)
      | h :: t ->
          let x', y', z' = move (x, y, z) h in
          furthest := max !furthest (dist (x', y', z'));
          loop (x', y', z') t
    in
    let x, y, z = loop (0, 0, 0) data in
    (dist (x, y, z), !furthest)

  let part1 data =
    let dist, _ = solve data in
    dist |> string_of_int |> print_endline

  let part2 data =
    let _, furthest = solve data in
    furthest |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  run "ne,ne,ne";
  [%expect {|
    3
    3
  |}]

let%expect_test _ =
  run "ne,ne,sw,sw";
  [%expect {|
    0
    2
  |}]

let%expect_test _ =
  run "ne,ne,s,s";
  [%expect {|
    2
    2
  |}]

let%expect_test _ =
  run "se,sw,se,sw,sw";
  [%expect {|
    3
    3
  |}]
