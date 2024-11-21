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
  let sod = invert_negative_term sod in 
  printf "%s\n" (string_of_expanded_expr sod)

(* testing uniform expectations *)
let _ = 
  let filename = "Example.txt" in
  let (vars, f) = process_input filename in
  let f_exp = expand_and_simplify f in
  let e1 = expectation_of_expanded_expr f_exp vars in
  let f_exp_sep = separate_expanded_expr f_exp in 
  let e2 = expectation_of_expanded_expr f_exp_sep vars in
  printf "%f\n" e1; printf "%f\n" e2

let _ =
  let a = normal_nth_moment_pos 2 (-3.) 1. in 
  let b = normal_nth_moment_pos 3 (-1.) 2. in 
  let c = normal_nth_moment_pos 4 (-2.) 3. in
  print_endline (string_of_float a);
  print_endline (string_of_float b);
  print_endline (string_of_float c)