module M = struct
  type t = string list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'

  let part1 data =
    data |> List.fold_left (fun acc line -> acc ^ line) "" |> print_endline

  let part2 data =
    data |> List.fold_left (fun acc line -> acc ^ line) "" |> print_endline
end

include M
include Day.Make (M)

let example = {|
foo
bar
|}

let%expect_test _ =
  run example;
  [%expect {|
    foobar
    foobar
  |}]
