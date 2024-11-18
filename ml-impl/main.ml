open Expr
open Input_parser
open Printf

let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in 
  printf "%s\n" (string_of_expr f);
  printf "%s\n" (string_of_distr (Hashtbl.find vars "x"));
  printf "%s\n" (string_of_distr (Hashtbl.find vars "y"));
  printf "%s\n" (string_of_distr (Hashtbl.find vars "z"))