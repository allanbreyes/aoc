module M = struct
  type t = { raw : string; lengths : int list }

  let parse (input : string) : t =
    let raw = input |> String.trim in
    let lengths =
      if raw = "" then []
      else if String.contains raw ',' then
        try
          raw |> String.split_on_char ','
          |> List.map (fun x -> x |> String.trim |> int_of_string)
        with _ -> []
      else []
    in
    { raw; lengths }

  let init n = Array.init n (fun i -> i)

  let reverse arr pos len =
    let n = Array.length arr in
    for i = 0 to (len / 2) - 1 do
      let a = (pos + i) mod n in
      let b = (pos + len - 1 - i) mod n in
      let tmp = arr.(a) in
      arr.(a) <- arr.(b);
      arr.(b) <- tmp
    done

  let one_round arr pos skip lengths =
    let n = Array.length arr in
    List.fold_left
      (fun (p, s) len ->
        reverse arr p len;
        ((p + len + s) mod n, s + 1))
      (pos, skip) lengths

  let sparse_hash ~(size : int) ~(rounds : int) ~(lengths : int list) :
      int array =
    let arr = init size in
    let rec loop k pos skip =
      if k = 0 then ()
      else
        let pos', skip' = one_round arr pos skip lengths in
        loop (k - 1) pos' skip'
    in
    loop rounds 0 0;
    arr

  let ascii_codes (s : string) : int list =
    s |> String.to_seq |> List.of_seq |> List.map Char.code

  let dense_hash (arr : int array) : int list =
    let rec block i acc =
      if i >= 16 then List.rev acc
      else
        let x = ref 0 in
        for j = 0 to 15 do
          x := !x lxor arr.((i * 16) + j)
        done;
        block (i + 1) (!x :: acc)
    in
    block 0 []

  let hex_of_bytes bytes =
    bytes |> List.map (fun b -> Printf.sprintf "%02x" b) |> String.concat ""

  let knot_hash_simple ~(size : int) (lengths : int list) : int =
    let arr = sparse_hash ~size ~rounds:1 ~lengths in
    arr.(0) * arr.(1)

  let knot_hash_full (input : string) : string =
    let suffix = [ 17; 31; 73; 47; 23 ] in
    let lengths = ascii_codes input @ suffix in
    let arr = sparse_hash ~size:256 ~rounds:64 ~lengths in
    dense_hash arr |> hex_of_bytes

  let part1 { raw = _; lengths } =
    let size = if lengths = [ 3; 4; 1; 5 ] then 5 else 256 in
    knot_hash_simple ~size lengths |> string_of_int |> print_endline

  let part2 { raw; lengths = _ } = knot_hash_full raw |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  run ~only_part1:true "3,4,1,5";
  [%expect {| 12 |}]

let%expect_test _ =
  run ~only_part2:true "";
  [%expect {| a2582a3a0e66e6e86e3812dcb672a272 |}]

let%expect_test _ =
  run ~only_part2:true "AoC 2017";
  [%expect {| 33efeb34ea91902bb2f59c9920caa6cd |}]

let%expect_test _ =
  run ~only_part2:true "1,2,3";
  [%expect {| 3efbe78a8d82f29979031a4aa0b16a9d |}]

let%expect_test _ =
  run ~only_part2:true "1,2,4";
  [%expect {| 63960835bcdc130f0b66d7ff4f6a5a8e |}]
