open Printf
open Expr

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
      (String.trim var, range_type, float_of_string lower_bound, float_of_string upper_bound)
    | _ -> failwith "Invalid variable declaration"
  with _ -> failwith "Invalid variable declaration"

let file_to_vardecs_expr filename = 
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

let vardec_tuple_to_distr (name, distribution, low, hi) = 
  match distribution with 
  | "U" -> Uniform (low, hi)
  | "N" -> Normal (low, hi)
  | "E" -> Exponential (low, hi)
  | "W" -> Wide (low, hi)
  | _ -> failwith "Invalid variable declaration"  

let vardecs_parser vardecs =
  let vars = Hashtbl.create 20 in 
  List.iter (fun (name, distribution, low, hi) -> 
    Hashtbl.add vars name (vardec_tuple_to_distr (name, distribution, low, hi));
    (* printf "(%s, %s, %f, %f)\n" name distribution low hi *)
  ) vardecs; vars

let expr_parser expr = 
  let lexbuf = Lexing.from_string expr in 
  try 
    let result = Parser.main Lexer.token lexbuf in result 
  with 
  | _ -> failwith "Invalid input expression"

let process_input filename = 
  let (vardecs, expr) = file_to_vardecs_expr filename in 
  match expr with 
  | Some expr -> let f = expr_parser expr in (vardecs_parser vardecs, f)
  | None -> failwith "No expression found"
