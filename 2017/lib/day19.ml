module M = struct
  type point = int * int
  type t = char array array * point

  let parse (input : string) : t =
    let lines =
      input |> String.split_on_char '\n'
      |> List.filter (fun s -> String.length s > 0)
    in
    let width =
      lines |> List.fold_left (fun m s -> max m (String.length s)) 0
    in
    let grid =
      lines
      |> List.map (fun line ->
          let arr = Array.make width ' ' in
          String.iteri (fun k ch -> arr.(k) <- ch) line;
          arr)
      |> Array.of_list
    in
    let j =
      match grid.(0) |> Array.find_index (fun c -> c = '|') with
      | Some j -> j
      | None -> failwith "no start '|' in first row"
    in
    let start = (0, j) in
    (grid, start)

  let dirs = [| (-1, 0); (0, 1); (1, 0); (0, -1) |]
  let delta d = dirs.(d)
  let is_letter c = 'A' <= c && c <= 'Z'

  let step (i, j) dir =
    let di, dj = delta dir in
    (i + di, j + dj)

  let get grid (i, j) =
    if i < 0 || i >= Array.length grid then ' '
    else
      let row = grid.(i) in
      if j < 0 || j >= Array.length row then ' ' else row.(j)

  let walk (grid, (i0, j0)) =
    let letters = Buffer.create 32 in
    let rec aux (i, j) dir steps =
      match get grid (i, j) with
      | ' ' -> (Buffer.contents letters, steps)
      | '+' ->
          let turns = [ (dir + 1) mod 4; (dir + 3) mod 4 ] in
          let dir' =
            match
              turns
              |> List.find_opt (fun d ->
                  let di, dj = delta d in
                  get grid (i + di, j + dj) <> ' ')
            with
            | Some d -> d
            | None -> dir
          in
          aux (step (i, j) dir') dir' (steps + 1)
      | c ->
          if is_letter c then Buffer.add_char letters c;
          aux (step (i, j) dir) dir (steps + 1)
    in
    aux (i0, j0) 2 0

  let part1 data =
    let letters, _steps = walk data in
    print_endline letters

  let part2 data =
    let _letters, steps = walk data in
    steps |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example =
  {|
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
|}

let%expect_test _ =
  run example;
  [%expect {|
    ABCDEF
    38
  |}]
