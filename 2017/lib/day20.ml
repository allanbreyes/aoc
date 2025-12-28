module M = struct
  type point = int * int * int
  type particle = { p : point; v : point; a : point }
  type t = particle list

  let parse_line (line : string) : particle option =
    try
      Scanf.sscanf line "p=<%d,%d,%d>, v=<%d,%d,%d>, a=<%d,%d,%d>"
        (fun px py pz vx vy vz ax ay az ->
          Some { p = (px, py, pz); v = (vx, vy, vz); a = (ax, ay, az) })
    with _ -> None

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n' |> List.map String.trim
    |> List.filter (fun s -> String.length s > 0)
    |> List.filter_map parse_line

  let manhattan (x, y, z) = abs x + abs y + abs z
  let key (p : particle) = (manhattan p.a, manhattan p.v, manhattan p.p)

  let part1 = function
    | [] -> print_endline "0"
    | p0 :: ps ->
        let rec aux (best_i, best_p) i = function
          | [] -> best_i
          | p :: tl ->
              let best_i, best_p =
                if compare (key p) (key best_p) < 0 then (i, p)
                else (best_i, best_p)
              in
              aux (best_i, best_p) (i + 1) tl
        in
        aux (0, p0) 1 ps |> string_of_int |> print_endline

  let add (x1, y1, z1) (x2, y2, z2) = (x1 + x2, y1 + y2, z1 + z2)

  let step_particle ({ p; v; a } : particle) : particle =
    let v = add v a in
    { p = add p v; v; a }

  let tick (ps : t) : t =
    let moved = List.map step_particle ps in
    let module P3 = struct
      type t = int * int * int

      let compare = compare
    end in
    let module M = Map.Make (P3) in
    let counts =
      List.fold_left
        (fun m { p; _ } ->
          M.update p (function None -> Some 1 | Some n -> Some (n + 1)) m)
        M.empty moved
    in
    List.filter
      (fun { p; _ } ->
        match M.find_opt p counts with Some 1 -> true | _ -> false)
      moved

  let rec settle stable prev_len ps =
    if stable >= 100 then ps
    else
      let next = tick ps in
      let len = List.length next in
      let stable' = if len = prev_len then stable + 1 else 0 in
      settle stable' len next

  let part2 data =
    let remaining = settle 0 (List.length data) data in
    remaining |> List.length |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example1 =
  {|
    p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
    p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
  |}

let%expect_test _ =
  run ~only_part1:true example1;
  [%expect {|
    0
  |}]
