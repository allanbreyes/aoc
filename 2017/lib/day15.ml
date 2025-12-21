module M = struct
  type t = int * int

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = line |> String.split_on_char ' ' in
        List.nth parts 4 |> String.trim |> int_of_string)
    |> function
    | [ a; b ] -> (a, b)
    | _ -> failwith "Expected two lines of input"

  let generate ~factor ~modulo ~multiple value =
    let rec next a =
      let a' = a * factor mod modulo in
      if a' mod multiple <> 0 then next a' else a'
    in
    next value

  let simulate ?(picky = false) ~n data =
    let factors = (16807, 48271) in
    let modulo = 2147483647 in
    let count = ref 0 in
    let rec loop a b n =
      let mult_a = if picky then 4 else 1 in
      let mult_b = if picky then 8 else 1 in
      let a' = generate ~factor:(fst factors) ~modulo ~multiple:mult_a a in
      let b' = generate ~factor:(snd factors) ~modulo ~multiple:mult_b b in
      if a' land 0xFFFF = b' land 0xFFFF then incr count;
      if n > 0 then loop a' b' (n - 1) else !count
    in
    loop (fst data) (snd data) n

  let part1 data = simulate ~n:40_000_000 data |> string_of_int |> print_endline

  let part2 data =
    simulate ~picky:true ~n:5_000_000 data |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
Generator A starts with 65
Generator B starts with 8921
|}

let%expect_test _ =
  run example;
  [%expect {|
    588
    309
  |}]
