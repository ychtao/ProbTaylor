open Expr
open Input_parser
open Printf
open Ops
open Expectation
open Error2
open Unix

(* let _  = 
  let (vars, f) = process_input "./benchmarks/Example.txt" in
  let f = expand_and_simplify f in 
  let x = expectation_of_expanded_expr f vars in
  print_endline ("x: " ^ (string_of_float x)) *)

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

let rec get_num_denom_single vars e = 
  match e with 
  | Div (f1, f2) -> (f1, f2) 
  | Mul (f1, f2) -> 
    let (num1, den1) = get_num_denom_single vars f1 in
    let (num2, den2) = get_num_denom_single vars f2 in
    (Mul (num1, num2), Mul (den1, den2))
  | _ -> failwith "get_num_denom_single: e is not a single fraction"

let get_hiqs vars lod f_denom = 
  let q2 = Mul (f_denom, f_denom) in
  let times_q2 = fun hi -> 
    let (num, den) = get_num_denom vars (Mul (hi, q2)) in 
    expand_and_simplify num in 
  List.map times_q2 lod


(* -1: search for the left half in the next iteration *)  
(* 0: the answer is found *)
(* 1: search for hte right half in the next iteration *)
(* Currently not used in the above way, instead only output *)
(* the computed upper bound for violation probability *)
let bin_search_u_flag vars eps p q2 u c order thres : float = 
  let k_u = add_expanded_exprs (const_times_expanded_expr eps p)
    (const_times_expanded_expr (-. u) q2) in 
  (* print_endline ("k_u: " ^ (string_of_expanded_expr k_u)); *)
  let mu =  expectation_of_expanded_expr k_u vars in
  (* print_endline ("mu: " ^ (string_of_float mu)); *)
  (* flag_float_num = (Ku - mu)^order *)
  let flag_float_num = simplify_expanded_expr (power_of_expanded_expr 
    (add_expanded_exprs k_u (const_expanded_expr (-. mu))) (int_of_float order)) in
    
  (* print_endline ("flag_float_num: " ^ (string_of_expanded_expr flag_float_num)); *)
  (* flag_float = E[flag_float_num] / mu^order *)
  let flag_float = (expectation_of_expanded_expr flag_float_num vars) /. (mu ** order) in 
  flag_float

(* order must be even *)
let rec bin_search_u vars eps p q2 c thres left right : float =
  1.

(* For testing *)
let u_init vars k eps p q2 = 
  let ep = expectation_of_expanded_expr p vars in 
  let eq2 = expectation_of_expanded_expr q2 vars in
  k *. eps *. (ep /. eq2)

(* For testing *)
let q2_var vars q2 n= 
  let eq2 = expectation_of_expanded_expr q2 vars in
  let a = add_expanded_exprs q2 (const_expanded_expr (-. eq2)) in 
  let b = const_times_expanded_expr (1. /. eq2) a in 
  let c = power_of_expanded_expr b (2 * n) in 
  expectation_of_expanded_expr c vars

let rec cartesian_product = function
  | [] -> [[]]
  | xs :: xss ->
      let rest = cartesian_product xss in
      List.flatten (List.map (fun x -> List.map (fun r -> x :: r) rest) xs)

let split_var_aux (distribution : Expr.distr) num_interval = 
  match distribution with 
  | Uniform (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in 
    let rec aux i acc = 
      if i >= num_interval then acc
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        aux (i + 1) ((Uniform (new_low, new_hi)) :: acc)
      in aux 0 []
  | _ -> failwith "split_var: Unsupported distribution type"

let split_var (name, distribution) num_interval = 
  let split_distribution = split_var_aux distribution num_interval in
  List.map (fun d -> (name, d)) split_distribution

let split_vars vars num_interval =
  let vars_list = Hashtbl.fold (fun key value acc -> (key, value) :: acc) vars [] in
  let split_var_list = List.map (fun (name, distribution) -> split_var (name, distribution) num_interval) vars_list in
  let combinations = cartesian_product split_var_list in
  List.map hashtbl_of_list combinations

(* Test split_vars *)
(* let _ = 
  let filename = Sys.argv.(1) in
  let (vars, f) = process_input filename in
  let num_interval = 2 in
  let split_vars_result = split_vars vars num_interval in
  List.iter (fun combination ->
    List.iter (fun (key, distribution) ->
      match distribution with
      | Uniform (low, hi) -> Printf.printf "%s: U(%f, %f)\n" key low hi
      | Normal (low, hi) -> Printf.printf "%s: N(%f, %f)\n" key low hi
      | Exponential (low, hi) -> Printf.printf "%s: E(%f, %f)\n" key low hi
    ) combination;
    print_newline ()
  ) split_vars_result *)

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let num_intervals = 16 in 
  let order = 2. in 
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in
  (* List.iter (fun d -> print_endline (string_of_expr d)) lod; *)
  let (f_num, f_denom) = get_num_denom_single vars f in
  let hiqs = get_hiqs vars lod f_denom in 
  (* List.iter (fun hi -> print_endline (string_of_expanded_expr hi)) hiqs; *)
  let sod = sum_of_expanded_exprs hiqs in
  (* print_endline ("sod: " ^ (string_of_expanded_expr sod)); *)
  let p = invert_negative_term (separate_expanded_expr sod) in 
  (* print_endline ("p: " ^ (string_of_expanded_expr p)); *)
  let q2 = power_of_expanded_expr (expand_and_simplify f_denom) 2 in
  (* print_endline ("q2: " ^ (string_of_expanded_expr q2)); *)
  (* let u = u_init vars 2. eps p q2 in
  print_endline ("u: " ^ (string_of_float u)); *)
  (* let q2_var = q2_var vars q2 4 in 
  print_endline ("q2_var: " ^ (string_of_float q2_var)); *)
  let u = float_of_string Sys.argv.(2) in 
  let sep_vars = split_vars vars num_intervals in 
  let counter = ref 0 in 
  let sum = ref 0. in 
  List.iter (fun subvars ->
    incr counter;
    let flag_float = bin_search_u_flag subvars eps p q2 u c order 1e-6 in
    sum := !sum +. (if flag_float > 1. then 1. else flag_float);
    (* Printf.printf "Combination %d: %f \n" !counter flag_float *)
    ) sep_vars ;
  Printf.printf "Number of intervals: %d \n" num_intervals;
  print_endline ("Threshold u: " ^ (string_of_float u));
  Printf.printf "Violation probability upper bound: %f \n" (!sum /. float_of_int !counter);
  (* let flag_float = bin_search_u_flag vars eps p q2 2e-3 c order 1e-6 in 
  print_endline (filename ^ " " ^ (string_of_float flag_float)); *)


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
