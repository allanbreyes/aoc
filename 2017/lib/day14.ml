module M = struct
  type t = string

  let parse (input : string) : t = input |> String.trim
  let knot_hash x = Day10.knot_hash_full x

  let hex_nibble (c : char) : int =
    if c >= '0' && c <= '9' then Char.code c - Char.code '0'
    else if c >= 'a' && c <= 'f' then 10 + (Char.code c - Char.code 'a')
    else invalid_arg "hex_nibble: expected hex digit"

  let ones (c : char) : int =
    let pop4 = [| 0; 1; 1; 2; 1; 2; 2; 3; 1; 2; 2; 3; 2; 3; 3; 4 |] in
    pop4.(hex_nibble c land 0xF)

  let part1 data =
    let row_sum r =
      knot_hash (data ^ "-" ^ string_of_int r)
      |> String.to_seq
      |> Seq.fold_left (fun acc c -> acc + ones c) 0
    in
    let rec loop r acc =
      if r = 128 then acc else loop (r + 1) (acc + row_sum r)
    in
    loop 0 0 |> string_of_int |> print_endline

  let part2 data =
    let width = 128 in
    let height = 128 in
    let total = width * height in
    let used = Array.make total false in
    let idx r c = (r * width) + c in
    for row = 0 to height - 1 do
      let hash = knot_hash (data ^ "-" ^ string_of_int row) in
      String.iteri
        (fun j c ->
          let n = hex_nibble c land 0xF in
          let base_col = j * 4 in
          for b = 0 to 3 do
            let mask = 1 lsl (3 - b) in
            let col = base_col + b in
            if n land mask <> 0 then used.(idx row col) <- true
          done)
        hash
    done;
    let ds = Utils.DSU.make_set total in
    for r = 0 to height - 1 do
      for c = 0 to width - 1 do
        let i = idx r c in
        if used.(i) then begin
          if c + 1 < width && used.(i + 1) then Utils.DSU.union ds i (i + 1);
          if r + 1 < height && used.(i + width) then
            Utils.DSU.union ds i (i + width)
        end
      done
    done;
    let groups =
      let rec loop i acc =
        if i = total then acc
        else
          let acc' =
            if used.(i) && Utils.DSU.find ds i = i then acc + 1 else acc
          in
          loop (i + 1) acc'
      in
      loop 0 0
    in
    groups |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let%expect_test _ =
  run "flqrgnkx";
  [%expect {|
    8108
    1242
  |}]
