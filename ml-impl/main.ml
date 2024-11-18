open Expr
open Input_parser
open Printf

let _ = 
  let filename = "Example.txt" in 
  let (vardecs, f) = process_input filename in 
  printf "%s\n" (string_of_expr f);