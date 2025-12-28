module M = struct
  type grid = char array array
  type t = (grid * grid) list
  type rule_map = (string, grid) Hashtbl.t

  let parse_grid (input : string) : grid =
    input |> String.trim |> String.split_on_char '/'
    |> List.map (fun s -> String.to_seq s |> Array.of_seq)
    |> Array.of_list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let pattern, result =
          Scanf.sscanf line "%s => %s" (fun pattern result -> (pattern, result))
        in
        (parse_grid pattern, parse_grid result))

  let key (g : grid) : string =
    let to_string (row : char array) : string =
      String.init (Array.length row) (fun j -> row.(j))
    in

    g |> Array.to_list |> List.map to_string |> String.concat "/"

  let rec rotate ?(times = 1) (g : grid) : grid =
    let n = Array.length g in
    if times = 0 then g
    else
      rotate ~times:(times - 1)
        (Array.init n (fun i -> Array.init n (fun j -> g.(n - j - 1).(i))))

  let flip (g : grid) : grid =
    let n = Array.length g in
    Array.init n (fun i ->
        let row = g.(i) in
        let m = Array.length row in
        Array.init m (fun j -> row.(m - j - 1)))

  let permute (g : grid) : grid list =
    let f = flip g in
    [
      g;
      rotate g;
      rotate ~times:2 g;
      rotate ~times:3 g;
      f;
      rotate f;
      rotate ~times:2 f;
      rotate ~times:3 f;
    ]

  let build_rule_map (rules : t) : rule_map =
    let h = Hashtbl.create (List.length rules * 8) in
    List.iter
      (fun (pat, out) ->
        permute pat |> List.iter (fun o -> Hashtbl.replace h (key o) out))
      rules;
    h

  let stitch (blocks : grid array array) : grid =
    let m = Array.length blocks in
    if m = 0 then [||]
    else
      let s = Array.length blocks.(0).(0) in
      Array.init (m * s) (fun i ->
          let bi = i / s in
          let ii = i mod s in
          Array.init (m * s) (fun j ->
              let bj = j / s in
              let jj = j mod s in
              blocks.(bi).(bj).(ii).(jj)))

  let rec enhance ~(n : int) (grid : grid) (rules : rule_map) : grid =
    if n = 0 then grid
    else
      let s = if Array.length grid mod 2 = 0 then 2 else 3 in
      let m = Array.length grid / s in
      let blocks =
        Array.init m (fun bi ->
            Array.init m (fun bj ->
                let sub =
                  Array.init s (fun di ->
                      Array.init s (fun dj ->
                          grid.((bi * s) + di).((bj * s) + dj)))
                in
                match Hashtbl.find_opt rules (key sub) with
                | Some g' -> g'
                | None -> failwith "no matching rule"))
      in
      enhance ~n:(n - 1) (stitch blocks) rules

  let count (g : grid) : int =
    Array.fold_left
      (fun acc row ->
        acc + Array.fold_left (fun a c -> if c = '#' then a + 1 else a) 0 row)
      0 g

  let solve ~(iterations : int) (rules : t) : int =
    let start = parse_grid ".#./..#/###" in
    count (enhance ~n:iterations start (build_rule_map rules))

  let part1 (rules : t) =
    let iterations = if List.length rules <= 2 then 2 else 5 in
    solve ~iterations rules |> string_of_int |> print_endline

  let part2 (rules : t) =
    solve ~iterations:18 rules |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example = {|
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
|}

let%expect_test _ =
  run ~only_part1:true example;
  [%expect {|
    12
  |}]
