open Expr
open Input_parser
open Printf
open Ops
open Expectation

let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let sod = sum_of_ei_diffs tf k in 
  let sod = expand_and_simplify sod in 
  let sod = separate_expanded_expr sod in
  let sod = invert_negative_term sod in (* is this invert correct? *)
  printf "%s\n" (string_of_expanded_expr sod);
  let sod2 = power_of_expanded_expr sod 2 in  
  printf "%s\n" (string_of_expanded_expr sod2)
