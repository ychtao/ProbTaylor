open Expr
open Input_parser
open Printf
open Ops
open Expectation
open Error2
open Unix

let get_num_denom vars e = 
  let oc = open_out "e.txt" in 
  Hashtbl.iter (fun key _ -> fprintf oc "%s\n" key) vars;
  fprintf oc "\n";
  fprintf oc "%s\n" (string_of_expr e);
  close_out oc;
  let _ = Sys.command "python num_denom.py" in 
  let ic = open_in "num_denom.txt" in
  let num = expr_parser (input_line ic) in
  let denom = expr_parser (input_line ic) in
  close_in ic;
  Sys.remove "e.txt";
  Sys.remove "num_denom.txt";
  (num, denom)


let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in
  let c = 0.99 in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in 
  let (nums, denoms) = List.split (List.map (get_num_denom vars) lod) in
  (* print every term in nums *)
  (* List.iter (fun num -> print_endline (string_of_expr num)) nums; *)
  (* print every term in denoms *)
  (* List.iter (fun denom -> print_endline (string_of_expr denom)) denoms; *)
  let denoms_product = List.fold_left (fun acc denom -> simplify (Mul (acc, denom))) (List.hd denoms) (List.tl denoms) in
  let nums_prime = List.map (fun num -> simplify (Mul (num, denoms_product))) nums in
  let nums_prime_sum = List.fold_left (fun acc num -> simplify (Add (acc, num))) (List.hd nums_prime) (List.tl nums_prime) in
  let pp = expand_expr nums_prime_sum in
  print_endline ("pp: " ^ (string_of_expanded_expr pp));
  let p = invert_negative_term (separate_expanded_expr (expand_and_simplify nums_prime_sum)) in
  print_endline ("p: " ^ (string_of_expanded_expr p));
