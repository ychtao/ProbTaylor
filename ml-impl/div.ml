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

let get_num_denom_single vars e = 
  match e with 
  | Div (f1, f2) -> (f1, f2) 
  | Mul (f1, f2) -> 
    let (num1, den1) = get_num_denom_single vars f1 in
    let (num2, den2) = get_num_denom_single vars f2 in
    (Mul (num1, num2), Mul (den1, den2))
  | _ -> failwith "get_num_denom_single: e is not a single fraction"

let get_hips vars lod f_denom = 
  let q2 = Mul (f_denom, f_denom) in
  let times_q2 = fun hi -> 
    let (num, den) = get_num_denom vars (Mul (hi, q2)) in 
    (* print_endline ("num: " ^ (string_of_expr num)); *)
    print_endline ("den: " ^ (string_of_expr den));
    expand_and_simplify num in 
  List.map times_q2 lod

let sum_of_expanded_exprs (ees : expanded_expr list) : expanded_expr = 
  simplify_expanded_expr (List.flatten ees)
  
let _ = 
  let filename = Sys.argv.(1) in 
  (* let eps = 2. ** (-24.) in 
  let c = 0.99 in  *)
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in
  (* List.iter (fun d -> print_endline (string_of_expr d)) lod; *)
  let (f_num, f_denom) = get_num_denom_single vars f in
  let hips = get_hips vars lod f_denom in 
  List.iter (fun hi -> print_endline (string_of_expanded_expr hi)) hips;
  let sod = sum_of_expanded_exprs hips in
  print_endline ("sod: " ^ (string_of_expanded_expr sod));


(* let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in
  let c = 0.99 in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in 
  List.iter (fun d -> print_endline (string_of_expr d)) lod;
  let (nums, denoms) = List.split (List.map (get_num_denom vars) lod) in
  (* denoms_product is D in the manuscript *)
  let denoms_product = List.fold_left (fun acc denom -> simplify (Mul (acc, denom))) (List.hd denoms) (List.tl denoms) in
  let nums_prime = List.map (fun num -> simplify (Mul (num, denoms_product))) nums in
  (* nums_prime_sum is the N in the manuscript *)
  let nums_prime_sum = List.fold_left (fun acc num -> simplify (Add (acc, num))) (List.hd nums_prime) (List.tl nums_prime) in
  (* print_endline ("nums_prime_sum: " ^ (string_of_expr nums_prime_sum)); *)
  let pp = expand_expr nums_prime_sum in
  print_endline ("pp: " ^ (string_of_expanded_expr pp));
  let p = invert_negative_term (separate_expanded_expr (expand_and_simplify nums_prime_sum)) in
  print_endline ("p: " ^ (string_of_expanded_expr p)); *)
