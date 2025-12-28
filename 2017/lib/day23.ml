module M = struct
  type xarg = Register of string
  type yarg = Register of string | Value of int

  type instruction =
    | Set of xarg * yarg
    | Sub of xarg * yarg
    | Mul of xarg * yarg
    | Jnz of yarg * yarg

  type t = instruction array

  let parse_yarg (input : string) : yarg =
    match int_of_string_opt input with
    | Some n -> Value n
    | None -> Register input

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = line |> String.split_on_char ' ' in
        match parts with
        | [ "set"; x; y ] -> Set (Register x, parse_yarg y)
        | [ "sub"; x; y ] -> Sub (Register x, parse_yarg y)
        | [ "mul"; x; y ] -> Mul (Register x, parse_yarg y)
        | [ "jnz"; x; y ] -> Jnz (parse_yarg x, parse_yarg y)
        | _ -> failwith ("Invalid instruction: " ^ line))
    |> Array.of_list

  let run ?(a = 0) (data : t) =
    let registers = Hashtbl.create 8 in
    let get r = Hashtbl.find_opt registers r |> Option.value ~default:0 in
    let set r v = Hashtbl.replace registers r v in
    let resolve = function Register r -> get r | Value v -> v in
    set "a" a;
    let rec loop i acc =
      if i < 0 || i >= Array.length data then (acc, get "h")
      else
        let instruction = data.(i) in
        match instruction with
        | Set (Register x, y) ->
            set x (resolve y);
            loop (i + 1) acc
        | Sub (Register x, y) ->
            set x (resolve (Register x) - resolve y);
            loop (i + 1) acc
        | Mul (Register x, y) ->
            set x (resolve (Register x) * resolve y);
            loop (i + 1) (acc + 1)
        | Jnz (x, y) -> loop (i + if resolve x <> 0 then resolve y else 1) acc
    in
    loop 0 0

  let part1 data = run data |> fst |> string_of_int |> print_endline

  let part2 (data : t) =
    let b0, mul, addb, addc, step =
      Array.fold_left
        (fun (b0, mul, addb, addc, step) -> function
          | Set (Register "b", Value v) -> (Some v, mul, addb, addc, step)
          | Mul (Register "b", Value v) -> (b0, Some v, addb, addc, step)
          | Sub (Register "b", Value v) when v < 0 ->
              let k = -v in
              let addb =
                match addb with None -> Some k | Some x -> Some (max x k)
              in
              let step =
                match step with None -> Some k | Some x -> Some (min x k)
              in
              (b0, mul, addb, addc, step)
          | Sub (Register "c", Value v) when v < 0 ->
              (b0, mul, addb, Some (-v), step)
          | _ -> (b0, mul, addb, addc, step))
        (None, None, None, None, None)
        data
    in
    match (b0, mul, addb, addc, step) with
    | Some b0, Some m, Some inc_b, Some inc_c, Some step ->
        let start_b = (b0 * m) + inc_b in
        let end_c = start_b + inc_c in
        let is_prime n =
          if n < 2 then false
          else
            let rec loop d =
              if d * d > n then true
              else if n mod d = 0 then false
              else loop (d + 1)
            in
            loop 2
        in
        let rec count acc b =
          if b > end_c then acc
          else count (acc + if is_prime b then 0 else 1) (b + step)
        in
        count 0 start_b |> string_of_int |> print_endline
    | _ -> run ~a:1 data |> snd |> string_of_int |> print_endline
end

include M
include Day.Make (M)
