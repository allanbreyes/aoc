module M = struct
  type t = int array

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.filter (fun line -> not (CCString.is_empty line))
    |> List.map int_of_string |> Array.of_list

  let run data extended =
    let rec loop acc i =
      if i < 0 || i >= Array.length data then acc
      else
        let j = data.(i) in
        if extended && j >= 3 then data.(i) <- j - 1 else data.(i) <- j + 1;
        loop (acc + 1) (i + j)
    in
    loop 0 0

  let part1 data = run data false |> string_of_int |> print_endline
  let part2 data = run data true |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
0
3
0
1
-3
|}

let%expect_test _ =
  run example;
  [%expect {|
    5
    10
  |}]
