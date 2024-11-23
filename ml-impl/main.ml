open Expr
open Input_parser
open Printf
open Ops
open Expectation

let bound1 filename eps c order = 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let sod = sum_of_ei_diffs tf k in
  let p = invert_negative_term (separate_expanded_expr (expand_and_simplify sod)) in
  let pn = power_of_expanded_expr p order in
  let esod = expectation_of_expanded_expr pn vars in
  let bound = eps *. ((esod /. (1. -. c)) ** (1. /. (float_of_int order))) in
  bound

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let order = int_of_string Sys.argv.(2) in 
  let bound = bound1 filename eps c order in 
  print_endline (string_of_float bound)