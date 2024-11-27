open Expr
open Input_parser
open Printf
open Ops
open Expectation
open Error2
open Unix

let bound1_poly filename eps c order = 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let sod = simplify (sum_of_ei_diffs tf k) in
  let p = invert_negative_term (separate_expanded_expr (expand_and_simplify sod)) in
  let pn = power_of_expanded_expr p order in
  let esod = expectation_of_expanded_expr pn vars in
  let bound = eps *. ((esod /. (1. -. c)) ** (1. /. (float_of_int order))) in
  bound

(* let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let order = int_of_string Sys.argv.(2) in 
  let start_time = Unix.gettimeofday () in
  let bound = bound1_poly filename eps c order in 
  print_endline ("First order error bound = " ^ (string_of_float bound));
  let elapsed_time = Unix.gettimeofday () -. start_time in
  print_endline ("Elapsed time = " ^ (string_of_float elapsed_time) ^ " seconds") *)

(* let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let r2 = error2 tf k  in 
  print_endline (string_of_expr r2) *)

let _ = 
  let a = laplace_nth_moment_neg 2 (-0.02) 0.02 in 
  let b = laplace_nth_moment_neg 2 (-0.02) 0.05 in 
  let c = laplace_nth_moment_neg 2 (-0.05) 0.02 in 
  print_endline (string_of_float a);
  print_endline (string_of_float b);
  print_endline (string_of_float c)