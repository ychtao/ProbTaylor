open Expr
open Input_parser
open Printf
open Ops

let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let h1 = simpl_zero (simpl_zero (set_err_to_zero (diff_ei tf 1))) in 
  printf "tilde f : %s\n" (string_of_expr tf);
  printf "h1 : %s\n" (string_of_expr h1);