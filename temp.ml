open Expr
open Input_parser
open Printf
open Ops
open Expectation

let _ = 
  let (vars, f) = process_input "temp.txt" in 
  let rcd = Hashtbl.create 20 in 
  let f = expand_expr f in 
  let ret = expectation_of_expanded_expr_verbose f vars rcd in 
  printf "%f\n" (fst ret)