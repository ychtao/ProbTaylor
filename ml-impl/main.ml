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
  (* print_endline ("tf: " ^ (string_of_expr tf)); *)
  let sod = simplify (sum_of_ei_diffs tf k) in
  (* print_endline ("sod: " ^ (string_of_expr sod)); *)
  let p = invert_negative_term (separate_expanded_expr (expand_and_simplify sod)) in
  (* print_endline ("p: " ^ (string_of_expanded_expr p)); *)
  let pn = power_of_expanded_expr p order in
  (* print_endline ("pn: " ^ (string_of_expanded_expr pn)); *)
  let esod = expectation_of_expanded_expr pn vars in
  let bound = eps *. ((esod /. (1. -. c)) ** (1. /. (float_of_int order))) in
  bound

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let order = int_of_string Sys.argv.(2) in 
  let start_time = Unix.gettimeofday () in
  let bound = bound1_poly filename eps c order in 
  print_endline ("First order error bound = " ^ (string_of_float bound));
  let elapsed_time = Unix.gettimeofday () -. start_time in
  print_endline ("Elapsed time = " ^ (string_of_float elapsed_time) ^ " seconds")

(* Suppose oc has already been open *)
let print_ed_ranges oc vars k eps dlt = 
  let rec loop_e k i = 
    if i > k then ()
    else (fprintf oc "e%d:(-%e, %e)\n" i eps eps; loop_e k (i + 1)) in
  loop_e k 1;
  let rec loop_d k i = 
    if i > k then ()
    else (fprintf oc "d%d:(-%e, %e)\n" i dlt dlt; loop_d k (i + 1)) in
  loop_d k 1;
  let rec loop_p k i = 
    if i > 2 * k then ()
    else if i <= k then (fprintf oc "p%d:(-%e, %e)\n" i eps eps; loop_p k (i + 1))
    else (fprintf oc "p%d:(-%e, %e)\n" i dlt dlt; loop_p k (i + 1)) in
  loop_p k 1;
  Hashtbl.iter (fun var distr -> 
    match distr with 
    | Uniform (low, hi) -> fprintf oc "%s:(%e, %e)\n" var low hi
    | Normal (low, hi) -> fprintf oc "%s:(%e, %e)\n" var low hi
    | Exponential (low, hi) -> fprintf oc "%s:(%e, %e)\n" var low hi
  ) vars

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let dlt = 2. ** (-126.) in 
  (* let c = 0.99 in 
  let order = int_of_string Sys.argv.(2) in *)
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let error2 = error2 tf k in
  print_endline (string_of_expr tf);
  let oc = open_out "error2.txt" in
  print_ed_ranges oc vars k eps dlt;
  fprintf oc "%s\n" (string_of_expr error2);
  close_out oc

(* let _ = 
  let filename = "Example.txt" in 
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let r2 = error2 tf k  in 
  print_endline (string_of_expr r2) *)

