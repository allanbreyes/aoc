module M = struct
  type xarg = Register of string
  type yarg = Register of string | Value of int

  type instruction =
    | Snd of yarg
    | Set of xarg * yarg
    | Add of xarg * yarg
    | Mul of xarg * yarg
    | Mod of xarg * yarg
    | Rcv of xarg
    | Jgz of yarg * yarg

  type t = instruction array

  type prog = {
    regs : (string, int) Hashtbl.t;
    inbox : int Queue.t;
    mutable ip : int;
    id : int;
    mutable sent : int;
  }

  let parse_yarg (input : string) : yarg =
    match int_of_string_opt input with
    | Some n -> Value n
    | None -> Register input

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = line |> String.split_on_char ' ' in
        match parts with
        | [ "snd"; x ] -> Snd (parse_yarg x)
        | [ "set"; x; y ] -> Set (Register x, parse_yarg y)
        | [ "add"; x; y ] -> Add (Register x, parse_yarg y)
        | [ "mul"; x; y ] -> Mul (Register x, parse_yarg y)
        | [ "mod"; x; y ] -> Mod (Register x, parse_yarg y)
        | [ "rcv"; x ] -> Rcv (Register x)
        | [ "jgz"; x; y ] -> Jgz (parse_yarg x, parse_yarg y)
        | _ -> failwith "Invalid instruction")
    |> Array.of_list

  let execute1 (data : t) =
    let registers = Hashtbl.create (Array.length data) in
    let sound = ref 0 in
    let resolve = function
      | Register reg ->
          Hashtbl.find_opt registers reg |> Option.value ~default:0
      | Value v -> v
    in
    let rec loop i : int =
      if i < 0 || i >= Array.length data then
        failwith "terminated without recovery"
      else
        let instruction = data.(i) in
        match instruction with
        | Snd y ->
            sound := resolve y;
            loop (i + 1)
        | Set (Register x, y) ->
            Hashtbl.replace registers x (resolve y);
            loop (i + 1)
        | Add (Register x, y) ->
            let v = resolve (Register x) + resolve y in
            Hashtbl.replace registers x v;
            loop (i + 1)
        | Mul (Register x, y) ->
            let v = resolve (Register x) * resolve y in
            Hashtbl.replace registers x v;
            loop (i + 1)
        | Mod (Register x, y) ->
            let v = resolve (Register x) mod resolve y in
            Hashtbl.replace registers x v;
            loop (i + 1)
        | Rcv (Register x) ->
            let v = resolve (Register x) in
            if v <> 0 then !sound else loop (i + 1)
        | Jgz (x, y) ->
            if resolve x > 0 then loop (i + resolve y) else loop (i + 1)
    in
    loop 0

  let execute2 (data : t) =
    let len = Array.length data in
    let resolve regs = function
      | Register reg -> Hashtbl.find_opt regs reg |> Option.value ~default:0
      | Value v -> v
    in
    let create_prog id =
      let regs = Hashtbl.create 32 in
      Hashtbl.replace regs "p" id;
      { regs; inbox = Queue.create (); ip = 0; id; sent = 0 }
    in
    let p0 = create_prog 0 in
    let p1 = create_prog 1 in
    let can_step p =
      if p.ip < 0 || p.ip >= len then false
      else
        match data.(p.ip) with
        | Rcv _ -> not (Queue.is_empty p.inbox)
        | _ -> true
    in
    let step p other_inbox =
      if p.ip < 0 || p.ip >= len then ()
      else
        match data.(p.ip) with
        | Snd y ->
            let v = resolve p.regs y in
            Queue.add v other_inbox;
            if p.id = 1 then p.sent <- p.sent + 1;
            p.ip <- p.ip + 1
        | Set (Register x, y) ->
            Hashtbl.replace p.regs x (resolve p.regs y);
            p.ip <- p.ip + 1
        | Add (Register x, y) ->
            let v = resolve p.regs (Register x) + resolve p.regs y in
            Hashtbl.replace p.regs x v;
            p.ip <- p.ip + 1
        | Mul (Register x, y) ->
            let v = resolve p.regs (Register x) * resolve p.regs y in
            Hashtbl.replace p.regs x v;
            p.ip <- p.ip + 1
        | Mod (Register x, y) ->
            let v = resolve p.regs (Register x) mod resolve p.regs y in
            Hashtbl.replace p.regs x v;
            p.ip <- p.ip + 1
        | Rcv (Register x) ->
            if Queue.is_empty p.inbox then ()
            else
              let v = Queue.take p.inbox in
              Hashtbl.replace p.regs x v;
              p.ip <- p.ip + 1
        | Jgz (x, y) ->
            let offset = if resolve p.regs x > 0 then resolve p.regs y else 1 in
            p.ip <- p.ip + offset
    in
    let rec loop () : int =
      let progressed = ref false in
      if can_step p0 then (
        step p0 p1.inbox;
        progressed := true);
      if can_step p1 then (
        step p1 p0.inbox;
        progressed := true);
      if !progressed then loop () else p1.sent
    in
    loop ()

  let part1 data = execute1 data |> string_of_int |> print_endline
  let part2 data = execute2 data |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example1 =
  {|
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
|}

let example2 = {|
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
|}

let%expect_test _ =
  run ~only_part1:true example1;
  [%expect {|
    4
  |}]

let%expect_test _ =
  run ~only_part2:true example2;
  [%expect {|
    3
  |}]
