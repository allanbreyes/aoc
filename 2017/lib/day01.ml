module M = struct
  type t = int array

  let int_of_char c = Char.code c - Char.code '0'

  let parse (input : string) : t =
    input |> String.trim |> String.to_seq |> Array.of_seq
    |> Array.map int_of_char

  let solve digits (jump : bool) =
    let n = Array.length digits in
    let step = if jump then n / 2 else 1 in
    Array.init n (fun i ->
        let j = (i + step) mod n in
        if digits.(i) = digits.(j) then digits.(i) else 0)
    |> Array.fold_left ( + ) 0

  let part1 digits =
    let ans = solve digits false in
    Printf.printf "%d\n" ans

  let part2 digits =
    let ans = solve digits true in
    Printf.printf "%d\n" ans
end

include M
include Day.Make (M)

let%expect_test _ =
  run "1122";
  [%expect {|
    3
    0
  |}]

let%expect_test _ =
  run "1111";
  [%expect {|
    4
    4
  |}]

let%expect_test _ =
  run "1234";
  [%expect {|
    0
    0
  |}]

let%expect_test _ =
  run "91212129";
  [%expect {|
    9
    6
  |}]

let%expect_test _ =
  run "1212";
  [%expect {|
    0
    6
  |}]

let%expect_test _ =
  run "1221";
  [%expect {|
    3
    0
  |}]

let%expect_test _ =
  run "123425";
  [%expect {|
    0
    4
  |}]

let%expect_test _ =
  run "123123";
  [%expect {|
    0
    12
  |}]

let%expect_test _ =
  run "12131415";
  [%expect {|
    0
    4
  |}]
