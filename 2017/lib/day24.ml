module M = struct
  type component = int * int
  type t = component list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        match String.split_on_char '/' line with
        | [ a; b ] -> (int_of_string a, int_of_string b)
        | _ -> failwith "invalid component")

  let bridge (components : t) : int * int =
    let remove target lst =
      let rec aux seen = function
        | [] -> List.rev seen
        | x :: xs when x = target -> List.rev_append seen xs
        | x :: xs -> aux (x :: seen) xs
      in
      aux [] lst
    in
    let q = Queue.create () in
    Queue.push (0, components, 0, 0) q;
    let rec loop best best_len best_len_strength =
      if Queue.is_empty q then (best, best_len_strength)
      else
        let port, remaining, strength, len = Queue.pop q in
        let best = max best strength in
        let best_length, best_length_strength =
          if len > best_len then (len, strength)
          else if len = best_len then (best_len, max best_len_strength strength)
          else (best_len, best_len_strength)
        in
        List.iter
          (fun ((a, b) as comp) ->
            if a = port || b = port then
              let next_port = if a = port then b else a in
              let remaining' = remove comp remaining in
              Queue.push (next_port, remaining', strength + a + b, len + 1) q)
          remaining;
        loop best best_length best_length_strength
    in
    loop 0 0 0

  let part1 data = bridge data |> fst |> string_of_int |> print_endline
  let part2 data = bridge data |> snd |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
|}

let%expect_test _ =
  run example;
  [%expect {|
    31
    19
  |}]
