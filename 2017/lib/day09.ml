module M = struct
  type t = char list

  let parse (input : string) : t =
    input |> String.trim |> String.to_seq |> List.of_seq

  type gstate = Clean | Trash
  type cstate = Pass | Skip

  let solve data =
    let score = ref 0 in
    let count = ref 0 in
    let depth = ref 0 in
    let state = ref (Clean, Pass) in

    let rec loop = function
      | [] -> ()
      | h :: t ->
          (match (h, fst !state, snd !state) with
          | _, g, Skip -> state := (g, Pass)
          | '{', Clean, Pass ->
              depth := !depth + 1;
              score := !score + !depth
          | '}', Clean, Pass -> depth := !depth - 1
          | '<', Clean, Pass -> state := (Trash, Pass)
          | '>', Trash, Pass -> state := (Clean, Pass)
          | '!', Trash, Pass -> state := (Trash, Skip)
          | ',', Clean, Pass -> ()
          | _, Trash, Pass -> count := !count + 1
          | _ -> ());
          loop t
    in
    loop data;
    (!score, !count)

  let part1 data = solve data |> fst |> string_of_int |> print_endline
  let part2 data = solve data |> snd |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  run ~only_part1:true "{}";
  [%expect {| 1 |}]

let%expect_test _ =
  run ~only_part1:true "{{{}}}";
  [%expect {| 6 |}]

let%expect_test _ =
  run ~only_part1:true "{{{},{},{{}}}}";
  [%expect {| 16 |}]

let%expect_test _ =
  run ~only_part1:true "{<a>,<a>,<a>,<a>}";
  [%expect {| 1 |}]

let%expect_test _ =
  run ~only_part1:true "{{<ab>},{<ab>},{<ab>},{<ab>}}";
  [%expect {| 9 |}]

let%expect_test _ =
  run ~only_part1:true "{{<!!>},{<!!>},{<!!>},{<!!>}}";
  [%expect {| 9 |}]

let%expect_test _ =
  run ~only_part1:true "{{<a!>},{<a!>},{<a!>},{<ab>}}";
  [%expect {| 3 |}]

let%expect_test _ =
  run ~only_part2:true "<>";
  [%expect {| 0 |}]

let%expect_test _ =
  run ~only_part2:true "<random characters>";
  [%expect {| 17 |}]

let%expect_test _ =
  run ~only_part2:true "<<<<>";
  [%expect {| 3 |}]

let%expect_test _ =
  run ~only_part2:true "<{!>}>";
  [%expect {| 2 |}]

let%expect_test _ =
  run ~only_part2:true "<!!>";
  [%expect {| 0 |}]

let%expect_test _ =
  run ~only_part2:true "<!!!>>";
  [%expect {| 0 |}]

let%expect_test _ =
  run ~only_part2:true "<{o\"i!a,<{i<a>";
  [%expect {| 10 |}]
