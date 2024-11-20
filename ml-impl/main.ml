open Expr
open Input_parser
open Printf
open Ops

let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let sod = sum_of_ei_diffs tf k in 
  let sod = expand_and_simplify sod in 
  let sod = separate_expanded_expr sod in
  let sod = invert_negative_term sod in 
  printf "%s\n" (string_of_expanded_expr sod)

let _ = 
  let f = expr_parser "x * (x * x + y + z) - x * z" in 
  let f = expand_and_simplify f in 
  let f = separate_expanded_expr f in 
  printf "expanded_expr: %s\n" (string_of_expanded_expr f);
  let f = expand_and_simplify (expanded_expr_to_expr f) in
  printf "expr : %s\n" (string_of_expanded_expr f)