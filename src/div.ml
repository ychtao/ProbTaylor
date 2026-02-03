open Expr
open Input_parser
open Printf
open Ops
(* open Expectation_num  *)
open Expectation
open Partition
open Error2
open Unix

let get_verbose () = 
  Array.exists (fun arg -> arg = "--verbose") Sys.argv

let get_num_denom vars e = 
  let oc = open_out "e.txt" in 
  Hashtbl.iter (fun key _ -> fprintf oc "%s\n" key) vars;
  fprintf oc "\n";
  fprintf oc "%s\n" (string_of_expr e);
  close_out oc;
  let _ = Sys.command "python3 ./src/num_denom.py" in 
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

let u_init vars eps p q2 = 
  let rcd = Hashtbl.create 20 in
  let (ep, rcd) = expectation_of_expanded_expr p vars rcd in 
  let (eq2, rcd) = expectation_of_expanded_expr q2 vars rcd in
  eps *. (ep /. eq2)

let div_flag_float_sub vars rcd eps p q2 u c order : float = 
  let k_u = add_expanded_exprs (const_times_expanded_expr eps p)
    (const_times_expanded_expr (-. u) q2) in 
  let mu =  fst (expectation_of_expanded_expr k_u vars rcd) in
  if mu >= 0. then 1. else 
  (* flag_float_num = (Ku - mu)^order *)
  let flag_float_num = simplify_expanded_expr (power_of_expanded_expr 
    (add_expanded_exprs k_u (const_expanded_expr (-. mu))) (int_of_float order)) in
  let flag_float = fst (expectation_of_expanded_expr flag_float_num vars rcd) /. (mu ** order) in 
  if flag_float > 1. then 1. else flag_float

let div_flag_float vars_weight_list rcd eps p q2 u c order : float = 
  let sum = List.fold_left (fun acc (vars, weight) ->
    let cur = div_flag_float_sub vars rcd eps p q2 u c order in 
    (* (if cur <= 0. then failwith "negative upper bound"); *)
    acc +. (cur *. weight)
  ) 0. vars_weight_list in 
  sum 

(* Order must be even *)
let rec div_bin_search vars_weight_list rcd eps p q2 c order left right : float =
  let mid = (left *. right) ** 0.5 in 
  (if get_verbose () then Printf.printf "left: %e; right: %e; mid: %e\n" left right mid; flush_all());
  let flag_float = div_flag_float vars_weight_list rcd eps p q2 mid c order in
  (if get_verbose () then Printf.printf "flag float: %e\n" flag_float; flush_all());
  if flag_float > 1. -. c then div_bin_search vars_weight_list rcd eps p q2 c order mid right 
  else if (right /. left) < 1.2 then mid 
  else div_bin_search vars_weight_list rcd eps p q2 c order left mid

(* let split_var_aux (distribution : Expr.distr) num_interval = 
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
  | _ -> failwith "split_var: Unsupported distribution type" *)

(* let split_var (name, distribution) num_interval = 
  let split_distribution = split_var_aux distribution num_interval in
  List.map (fun d -> (name, d)) split_distribution *)

(* let split_vars vars num_interval =
  let vars_list = Hashtbl.fold (fun key value acc -> (key, value) :: acc) vars [] in
  let split_var_list = List.map (fun (name, distribution) -> split_var (name, distribution) num_interval) vars_list in
  let combinations = cartesian_product split_var_list in
  List.map hashtbl_of_list combinations *)

let central_moment_based_div filename eps cfd order num_intervals : float =
  let rcd = Hashtbl.create 20 in 
  let order_float = float_of_int order in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let lod = list_of_ei_diffs tf k in 
  let (f_num, f_denom) = get_num_denom_single vars f in 
  let hiqs = get_hiqs vars lod f_denom in
  let sod = sum_of_expanded_exprs hiqs in 
  let p = simplify_expanded_expr (invert_negative_term (separate_expanded_expr_opt sod vars)) in
  let q2 = power_of_expanded_expr (expand_and_simplify f_denom) 2 in
  let u_init = u_init vars eps p q2 in 
  let vars_weight_list = split_vars_with_weight vars num_intervals in 
  (* Printf.printf "p : %s\n" (string_of_expanded_expr p); 
  Printf.printf "q2 : %s\n" (string_of_expanded_expr q2);
  Printf.printf "u_init: %e\n" u_init; flush_all (); *)
  let u = div_bin_search vars_weight_list rcd eps p q2 cfd order_float (u_init *. 1.01) (u_init *. 20000.) in 
  u


(* let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in
  let num_intervals = 32 in 
  let order = 2. in
  let rcd = Hashtbl.create 20 in 
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in
  let (f_num, f_denom) = get_num_denom_single vars f in
  let hiqs = get_hiqs vars lod f_denom in
  let sod = sum_of_expanded_exprs hiqs in
  let p = simplify_expanded_expr (invert_negative_term (separate_expanded_expr_opt sod vars)) in
  let q2 = power_of_expanded_expr (expand_and_simplify f_denom) 2 in
  let u_init = u_init vars eps p q2 in
  print_endline ("u_init: " ^ (string_of_float u_init));
  let vars_weight_list = split_vars_with_weight vars num_intervals in
  let u = bin_search_u_weighted vars_weight_list rcd eps p q2 c order (u_init *. 1.01) (u_init *. 20000.) in
  print_endline ("u: " ^ (string_of_float u)); *)

(* Test split_vars_with_weight *)
(* let _ = 
  let filename = Sys.argv.(1) in
  let (vars, f) = process_input filename in
  let num_interval = 4 in
  let vars_weight_list = split_vars_with_weight vars num_interval in
  List.iter (fun (vars, weight) ->
    List.iter (fun (key, distribution) ->
      match distribution with
      | Uniform (low, hi) -> Printf.printf "%s: U(%f, %f)\n" key low hi
      | Normal (low, hi) -> Printf.printf "%s: N(%f, %f)\n" key low hi
      | Exponential (low, hi) -> Printf.printf "%s: E(%f, %f)\n" key low hi
    ) vars;
    Printf.printf "Weight: %f\n" weight) vars_weight_list *)

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

(* Unweighted only *)
(* let _ = 
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
  let u_init = u_init vars eps p q2 in
  (* print_endline ("u: " ^ (string_of_float u)); *)
  let vars_list = split_vars vars num_intervals in 
  let u = bin_search_u vars_list eps p q2 c order (u_init *. 1.01) (u_init *. 20000.) in
  print_endline ("u: " ^ (string_of_float u))    *)
