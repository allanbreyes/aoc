module M = struct
  type t = int

  let parse (input : string) : t = input |> String.trim |> int_of_string

  let part1 number =
    (match number with
      | n when n <= 1 -> 0
      | _ ->
          let ring =
            int_of_float (ceil ((sqrt (float_of_int number) -. 1.) /. 2.))
          in
          let root = (ring * 2) - 1 in
          let ring_start = (root * root) + 1 in
          let offset = (number - ring_start) mod (ring * 2) in
          let side = abs (offset - (ring - 1)) in
          ring + side)
    |> string_of_int |> print_endline

  let part2 number =
    let at map (i, j) =
      Hashtbl.find_opt map (i, j) |> Option.value ~default:0
    in
    let base = (0, 0)
    and up (i, j) = (i - 1, j)
    and left (i, j) = (i, j - 1)
    and down (i, j) = (i + 1, j)
    and right (i, j) = (i, j + 1) in
    let neighbors =
      [
        base |> up;
        base |> up |> right;
        base |> right;
        base |> right |> down;
        base |> down;
        base |> down |> left;
        base |> left;
        base |> left |> up;
      ]
    in
    let value map (i, j) =
      List.fold_left
        (fun acc (di, dj) -> acc + at map (i + di, j + dj))
        0 neighbors
    in
    let next map pos =
      let seen p = at map p <> 0 in
      match
        [ up pos; right pos; down pos; left pos ] |> List.map (fun p -> seen p)
      with
      | [ false; false; _; true ] -> up pos
      | [ false; _; true; false ] -> left pos
      | [ _; true; false; false ] -> down pos
      | [ true; false; false; _ ] -> right pos
      | _ -> invalid_arg "no valid next position"
    in
    let map = Hashtbl.create number in
    Hashtbl.add map base 1;

    let rec spiral pos =
      let v = value map pos in
      if v > number then v
      else (
        Hashtbl.add map pos v;
        spiral (next map pos))
    in
    base |> right |> spiral |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  run ~only_part1:true "1";
  [%expect {| 0 |}]

let%expect_test _ =
  run ~only_part1:true "12";
  [%expect {| 3 |}]

let%expect_test _ =
  run ~only_part1:true "23";
  [%expect {| 2 |}]

let%expect_test _ =
  run ~only_part1:true "1024";
  [%expect {| 31 |}]

let%expect_test _ =
  run ~only_part2:true "800";
  [%expect {| 806 |}]
