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
  (* let h1 = simplify (set_err_to_zero (diff_ei tf 1)) in
  let h2 = simplify (set_err_to_zero (diff_ei tf 2)) in
  let h3 = simplify (set_err_to_zero (diff_ei tf 3)) in
  printf "tilde f : %s\n" (string_of_expr tf);
  printf "h1 : %s\n" (string_of_expr h1);
  printf "h2 : %s\n" (string_of_expr h2);
  printf "h3 : %s\n" (string_of_expr h3) *)

let _ = 
  let f = expr_parser "x * (x * x + y + z) - x * z" in 
  let f = expand_and_simplify f in 
  let f = separate_expanded_expr f in 
  printf "expanded and simplified : %s\n" (string_of_expanded_expr f)