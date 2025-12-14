open Containers

module M = struct
  type t = int array

  let parse (input : string) : t =
    input |> String.trim
    |> Str.split (Str.regexp "[ \t]+")
    |> List.filter (fun s -> not (CCString.is_empty s))
    |> List.map int_of_string |> Array.of_list

  let print banks =
    Array.to_seq banks |> Seq.to_list |> List.map string_of_int
    |> String.concat " " |> print_endline

  let rec run banks seen current =
    let snapshot = Array.copy banks in
    match Hashtbl.find_opt seen snapshot with
    | Some first -> (first, current)
    | None ->
        Hashtbl.add seen snapshot current;

        let len = Array.length banks in
        let max_i, max =
          let i = ref 0 and v = ref banks.(0) in
          for j = 1 to len - 1 do
            if banks.(j) > !v then (
              v := banks.(j);
              i := j)
          done;
          (!i, !v)
        in
        banks.(max_i) <- 0;

        let rec distribute rem i =
          if rem = 0 then ()
          else
            let next = (i + 1) mod len in
            banks.(next) <- banks.(next) + 1;
            distribute (rem - 1) next
        in
        distribute max max_i;

        run banks seen (current + 1)

  let solve ?(size = 10000) banks =
    let seen = Hashtbl.create size in
    run (Array.copy banks) seen 0

  let part1 data =
    let _, cycles = solve data in
    print_endline (string_of_int cycles)

  let part2 data =
    let first, cycles = solve data in
    print_endline (string_of_int (cycles - first))
end

include M
include Day.Make (M)

let example = {|
0	2	7	0
|}

let%expect_test _ =
  run example;
  [%expect {|
    5
    4
  |}]
