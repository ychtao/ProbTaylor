open Printf

let file_to_lines filename =
  let ic = open_in filename in
  let rec read_lines ic acc =
    try
      let line = input_line ic in
      read_lines ic (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_lines ic []

let process_vardec line = 
  try
    let parts = String.split_on_char ':' line in
    match parts with
    | [var; range] ->
      let range_parts = String.split_on_char '(' range in
      let range_type = String.trim (List.hd range_parts) in
      let bounds = String.split_on_char ',' (String.sub (List.nth range_parts 1) 0 (String.length (List.nth range_parts 1) - 1)) in
      let lower_bound = String.trim (List.hd bounds) in
      let upper_bound = String.trim (List.nth bounds 1) in
      (String.trim var, range_type, lower_bound, upper_bound)
    | _ -> failwith "Invalid variable declaration"
  with _ -> failwith "Invalid variable declaration"

let process_input filename = 
  let lines = file_to_lines filename in 
  let rec process_lines lines vardecs expr =
    match lines with 
    | [] -> (List.rev vardecs, expr)
    | line :: rest ->
      if String.contains line ':' then 
        let vardec = process_vardec line in 
        process_lines rest (vardec :: vardecs) expr 
      else
        process_lines rest vardecs (Some line)
  in process_lines lines [] None

(* let () =
  let filename = "Example.txt" in
  let (declarations, expression) = process_input filename in
  List.iter (fun (var, range_type, lower_bound, upper_bound) ->
    printf "(%s, %s, %s, %s)\n" var range_type lower_bound upper_bound
  ) declarations;
  match expression with
  | Some expr -> printf "Expression: %s\n" expr
  | None -> printf "No expression found\n" *)
