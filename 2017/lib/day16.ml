module M = struct
  type move = Spin of int | Exchange of int * int | Partner of string * string
  type t = move list

  let parse_token token =
    let op = String.get token 0 in
    let rest =
      String.sub token 1 (String.length token - 1) |> String.split_on_char '/'
    in
    match (op, rest) with
    | 's', [ x ] -> Spin (int_of_string x)
    | 'x', [ x; y ] -> Exchange (int_of_string x, int_of_string y)
    | 'p', [ a; b ] -> Partner (a, b)
    | _ -> failwith "Invalid token"

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char ',' |> List.map parse_token

  let to_arr s = s |> String.to_seq |> List.of_seq |> Array.of_list

  let from_arr arr =
    arr |> Array.to_list |> List.map (String.make 1) |> String.concat ""

  let spin x arr =
    let n = Array.length arr in
    let x = x mod n in
    Array.concat [ Array.sub arr (n - x) x; Array.sub arr 0 (n - x) ]

  let exchange x y arr =
    let arr' = Array.copy arr in
    arr'.(x) <- arr.(y);
    arr'.(y) <- arr.(x);
    arr'

  let partner a b arr =
    let rec find_index arr v i =
      if i >= Array.length arr then failwith "Character not found"
      else if arr.(i) = v then i
      else find_index arr v (i + 1)
    in
    let i_a = find_index arr a 0 in
    let i_b = find_index arr b 0 in
    exchange i_a i_b arr

  let perform arr = function
    | Spin x -> spin x arr
    | Exchange (x, y) -> exchange x y arr
    | Partner (a, b) -> partner (String.get a 0) (String.get b 0) arr

  let part1 moves =
    let start = if List.length moves > 5 then "abcdefghijklmnop" else "abcde" in
    List.fold_left perform (to_arr start) moves |> from_arr |> print_endline

  let part2 moves =
    let start = if List.length moves > 5 then "abcdefghijklmnop" else "abcde" in
    let next s = List.fold_left perform (to_arr s) moves |> from_arr in
    let seen = Hashtbl.create 256 in
    let order_rev = ref [] in
    let rec build i curr =
      if Hashtbl.mem seen curr then ()
      else (
        Hashtbl.add seen curr i;
        order_rev := curr :: !order_rev;
        build (i + 1) (next curr))
    in
    build 0 start;

    let order = List.rev !order_rev in
    let period = List.length order in
    1_000_000_000 mod period |> List.nth order |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  spin 3 (to_arr "abcde") |> from_arr |> print_endline;
  [%expect {| cdeab |}]

let%expect_test _ =
  exchange 3 4 (to_arr "eabcd") |> from_arr |> print_endline;
  [%expect {| eabdc |}]

let%expect_test _ =
  partner 'e' 'b' (to_arr "eabcd") |> from_arr |> print_endline;
  [%expect {| baecd |}]

let%expect_test _ =
  run "s1,x3/4,pe/b";
  [%expect {|
    baedc
    abcde
  |}]
