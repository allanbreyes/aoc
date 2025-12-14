module M = struct
  type t = string list

  let parse (input : string) : t =
    input |> String.trim |> String.split_on_char '\n'

  module StringSet = Set.Make (String)

  let valid password ~strong =
    let id x = x in
    let words line = String.split_on_char ' ' line in
    let sort s =
      s |> String.to_seq |> List.of_seq |> List.sort Char.compare |> List.to_seq
      |> String.of_seq
    in
    let count line =
      line |> words
      |> List.map (if strong then sort else id)
      |> StringSet.of_list |> StringSet.elements |> List.length
    in
    List.length (words password) = count password

  let part1 data =
    data
    |> List.filter (valid ~strong:false)
    |> List.length |> string_of_int |> print_endline

  let part2 data =
    data
    |> List.filter (valid ~strong:true)
    |> List.length |> string_of_int |> print_endline
end

include M
include Day.Make (M)

let example1 = {|
aa bb cc dd ee
aa bb cc dd aa
aa bb cc dd aaa
|}

let example2 =
  {|
abcde fghij
abcde xyz ecdab
a ab abc abd abf abj
iiii oiii ooii oooi oooo
oiii ioii iioi iiio
|}

let%expect_test _ =
  run ~only_part1:true example1;
  [%expect {| 2 |}]

let%expect_test _ =
  run ~only_part2:true example2;
  [%expect {| 3 |}]
