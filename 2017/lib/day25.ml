module M = struct
  type action = { write : int; move : int; continue : string }
  type rule = { off : action; on : action }
  type rules = (string, rule) Hashtbl.t
  type t = string * int * rules

  let parse (input : string) : t =
    let stanzas = input |> String.trim |> Str.split (Str.regexp "\n\n+") in
    let header_lines = List.hd stanzas |> String.split_on_char '\n' in
    let re1 = Str.regexp "Begin in state \\([A-Z]\\)\\." in
    let re2 =
      Str.regexp "Perform a diagnostic checksum after \\([0-9]+\\) steps\\."
    in
    let start =
      match List.find_opt (fun l -> Str.string_match re1 l 0) header_lines with
      | Some l -> Str.matched_group 1 l
      | None -> failwith "invalid header: start state"
    in
    let steps =
      match List.find_opt (fun l -> Str.string_match re2 l 0) header_lines with
      | Some l -> Str.matched_group 1 l |> int_of_string
      | None -> failwith "invalid header: steps"
    in
    let table : rules = Hashtbl.create (max 1 (List.length stanzas - 1)) in
    let re_in_state = Str.regexp "In state \\([A-Z]\\):" in
    let re_write = Str.regexp ".*Write the value \\([01]\\)\\." in
    let re_move = Str.regexp ".*Move one slot to the \\(right\\|left\\)\\." in
    let re_cont = Str.regexp ".*Continue with state \\([A-Z]\\)\\." in
    let parse_action lines i =
      if i + 2 >= List.length lines then failwith "invalid action block";
      let l_w = List.nth lines i in
      let l_m = List.nth lines (i + 1) in
      let l_c = List.nth lines (i + 2) in
      let write =
        if Str.string_match re_write l_w 0 then
          Str.matched_group 1 l_w |> int_of_string
        else failwith "invalid write line"
      in
      let move =
        if Str.string_match re_move l_m 0 then
          match Str.matched_group 1 l_m with
          | "right" -> 1
          | "left" -> -1
          | _ -> 0
        else failwith "invalid move line"
      in
      let continue =
        if Str.string_match re_cont l_c 0 then Str.matched_group 1 l_c
        else failwith "invalid continue line"
      in
      ({ write; move; continue }, i + 3)
    in
    let parse_stanza stanza =
      let lines =
        stanza |> String.split_on_char '\n'
        |> List.filter (fun s -> String.trim s <> "")
      in
      match lines with
      | state_line :: rest when Str.string_match re_in_state state_line 0 ->
          let state = Str.matched_group 1 state_line in
          (* Expect "If current value is 0:" then three lines, then "If current value is 1:" and three lines *)
          let rest =
            match rest with
            | _if0 :: tl -> tl
            | _ -> failwith "missing if-0 line"
          in
          let off_action, next_idx = parse_action rest 0 in
          let rec drop n l =
            if n <= 0 then l
            else match l with [] -> [] | _ :: tl -> drop (n - 1) tl
          in
          let rest' = drop next_idx rest in
          let rest'' =
            match rest' with
            | _if1 :: tl -> tl
            | _ -> failwith "missing if-1 line"
          in
          let on_action, _ = parse_action rest'' 0 in
          Hashtbl.replace table state { off = off_action; on = on_action }
      | _ -> failwith "invalid state stanza"
    in
    List.tl stanzas |> List.iter parse_stanza;
    (start, steps, table)

  module Set = Set.Make (Int)

  let part1 (start, steps, table) =
    let rec step n ones pos state =
      if n = 0 then Set.cardinal ones
      else
        let curr = if Set.mem pos ones then 1 else 0 in
        let tbl_state = Hashtbl.find table state in
        let action = if curr = 0 then tbl_state.off else tbl_state.on in
        let ones' =
          if action.write = 1 then Set.add pos ones else Set.remove pos ones
        in
        step (n - 1) ones' (pos + action.move) action.continue
    in
    step steps Set.empty 0 start |> string_of_int |> print_endline

  let part2 _ = print_endline "⭐"
end

include M
include Day.Make (M)

let example =
  {|
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
|}

let%expect_test _ =
  run example;
  [%expect {|
    3
    ⭐
  |}]
