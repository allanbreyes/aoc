module M = struct
  type registers = (string, int) Hashtbl.t
  type operation = Inc | Dec
  type condition = Gt | Lt | Eq | Ne | Ge | Le

  type instruction = {
    register : string;
    operation : operation;
    value : int;
    condition : condition;
    condition_register : string;
    condition_value : int;
  }

  type t = instruction list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'
    |> List.map (fun line ->
        let parts = line |> String.split_on_char ' ' |> Array.of_list in
        let op =
          match parts.(1) with
          | "inc" -> Inc
          | "dec" -> Dec
          | _ -> failwith "invalid operation"
        in
        let value = parts.(2) |> int_of_string in
        let cond_register = parts.(4) in
        let cond =
          match parts.(5) with
          | ">" -> Gt
          | "<" -> Lt
          | "==" -> Eq
          | "!=" -> Ne
          | ">=" -> Ge
          | "<=" -> Le
          | _ -> failwith "invalid condition"
        in
        let cond_value = parts.(6) |> int_of_string in
        {
          register = parts.(0);
          operation = op;
          value;
          condition = cond;
          condition_register = cond_register;
          condition_value = cond_value;
        })

  let solve instructions =
    let registers = Hashtbl.create (List.length instructions) in
    let largest = ref min_int in
    let get register =
      Hashtbl.find_opt registers register |> Option.value ~default:0
    in
    List.iter
      (fun instruction ->
        let register = instruction.register in
        let value = instruction.value in
        let condition = instruction.condition in
        let condition_value = instruction.condition_value in
        let satisfied =
          match condition with
          | Gt -> get instruction.condition_register > condition_value
          | Lt -> get instruction.condition_register < condition_value
          | Eq -> get instruction.condition_register = condition_value
          | Ne -> get instruction.condition_register <> condition_value
          | Ge -> get instruction.condition_register >= condition_value
          | Le -> get instruction.condition_register <= condition_value
        in

        (if satisfied then
           match instruction.operation with
           | Inc -> Hashtbl.replace registers register (get register + value)
           | Dec -> Hashtbl.replace registers register (get register - value));
        largest := max !largest (get register))
      instructions;

    ( registers |> Hashtbl.to_seq
      |> Seq.map (fun (_, value) -> value)
      |> Seq.fold_left max min_int,
      !largest )

  let part1 instructions =
    solve instructions |> fst |> string_of_int |> print_endline

  let part2 instructions =
    solve instructions |> snd |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example =
  {|
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10
|}

let%expect_test _ =
  run example;
  [%expect {|
    1
    10
  |}]
