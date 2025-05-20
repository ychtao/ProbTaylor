open Expr
open Input_parser
open Printf
open Ops
open Expectation
open Error2
open Unix

let _ = 
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 0 (-5.) (5.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 1 (-5.) (5.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 2 (-5.) (5.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 3 (-5.) (5.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 0 (-3.) (15.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 1 (-3.) (15.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 2 (-3.) (15.));
  Printf.printf "%f\n" (wide_normal_nth_moment_neg 3 (-3.) (15.))


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
(* 1: search for the right half in the next iteration *)
(* Currently not used in the above way, instead only output *)
(* the computed upper bound for violation probability *)
let u_flag_float_sub vars eps p q2 u c order : float = 
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
  if flag_float > 1. then 1. else flag_float

(* Unweighted, only for uniform distribution *)
let u_flag_float vars_list eps p q2 u c order : float = 
  let sum = List.fold_left (fun acc vars ->
    let cur = u_flag_float_sub vars eps p q2 u c order in 
    (* print_endline ("cur: " ^ (string_of_float cur)); *)
    acc +. cur
  ) 0. vars_list in 
  sum /. float_of_int (List.length vars_list)

let u_flag_float_weighted vars_weight_list eps p q2 u c order : float = 
  let sum = List.fold_left (fun acc (vars, weight) ->
    (* let distribution = Hashtbl.find vars "v" in 
    Printf.printf "v: %f, %f\n" (low_of_distr distribution) (high_of_distr distribution); *)
    let cur = u_flag_float_sub vars eps p q2 u c order in 
    (* print_endline ("cur: " ^ (string_of_float cur)); *)
    acc +. (cur *. weight)
  ) 0. vars_weight_list in 
  sum 

(* Order must be even *)
(* Unweighted, only for uniform distribution *)
let rec bin_search_u vars_list eps p q2 c order left right : float =
  Printf.printf "Left: %e, Right: %e\n" left right;
  let mid = (left *. right) ** 0.5 in 
  let flag_float = u_flag_float vars_list eps p q2 mid c order in
  Printf.printf "Mid: %e, Flag Float: %f\n" mid flag_float;
  print_endline "";
  if flag_float > 1. -. c then bin_search_u vars_list eps p q2 c order mid right 
  else if (right /. left) < 2. then mid 
  else bin_search_u vars_list eps p q2 c order left mid

let rec bin_search_u_weighted vars_weight_list eps p q2 c order left right : float =
  Printf.printf "Left: %e, Right: %e\n" left right;
  let mid = (left *. right) ** 0.5 in 
  let flag_float = u_flag_float_weighted vars_weight_list eps p q2 mid c order in
  Printf.printf "Mid: %e, Flag Float: %f\n" mid flag_float;
  print_endline "";
  if flag_float > 1. -. c then bin_search_u_weighted vars_weight_list eps p q2 c order mid right 
  else if (right /. left) < 2. then mid 
  else bin_search_u_weighted vars_weight_list eps p q2 c order left mid

let u_init vars eps p q2 = 
  (* print_endline ("p : " ^ (string_of_expanded_expr p)); *)
  let ep = expectation_of_expanded_expr p vars in 
  (* print_endline ("ep: " ^ (string_of_float ep)); *)
  if Float.is_infinite ep then failwith "ep is infinite";
  let eq2 = expectation_of_expanded_expr q2 vars in
  eps *. (ep /. eq2)

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

let rec cartesian_product_float = function 
  | [] -> [1. ]
  | xs :: xss ->
      let rest = cartesian_product_float xss in 
      List.flatten (List.map (fun x -> List.map (fun r -> x *. r) rest) xs)

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

let split_var_aux_with_weight (distribution : Expr.distr) num_interval : (Expr.distr list * float list) = 
  match distribution with 
  | Uniform (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in 
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        aux (i + 1) ((Uniform (new_low, new_hi)) :: acc_d) ((1. /. (float_of_int num_interval)) :: acc_w)
      in aux 0 [] []
  | Normal (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in
    let total_weight = standard_normal_cdf hi -. standard_normal_cdf low in
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        let weight = standard_normal_cdf new_hi -. standard_normal_cdf new_low in
        aux (i + 1) ((Normal (new_low, new_hi)) :: acc_d) ((weight /. total_weight) :: acc_w)
      in aux 0 [] []
  | Exponential (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in
    let total_weight = standard_laplace_cdf hi -. standard_laplace_cdf low in
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        let weight = standard_laplace_cdf new_hi -. standard_laplace_cdf new_low in
        aux (i + 1) ((Exponential (new_low, new_hi)) :: acc_d) ((weight /. total_weight) :: acc_w)
      in aux 0 [] []

let split_var_with_weight (name, distribution) num_interval : (string * Expr.distr) list * float list = 
  let (split_distribution, weights) = split_var_aux_with_weight distribution num_interval in
  let split_vars = List.map (fun d -> (name, d)) split_distribution in
  (split_vars, weights)

let split_vars_with_weight vars num_interval = 
  let vars_list = Hashtbl.fold (fun key value acc -> (key, value) :: acc) vars [] in
  let split_vars_list = List.map (fun (name, distribution) -> split_var_with_weight (name, distribution) num_interval) vars_list in
  let combinations = List.map hashtbl_of_list (cartesian_product (List.map fst split_vars_list)) in
  let weights = cartesian_product_float (List.map snd split_vars_list) in
  List.combine combinations weights

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

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in
  let num_intervals = 16 in 
  let order = 2. in
  let (vars, f) = process_input filename in
  let (tf, k) = tilde f in
  let lod = list_of_ei_diffs tf k in
  let (f_num, f_denom) = get_num_denom_single vars f in
  let hiqs = get_hiqs vars lod f_denom in
  let sod = sum_of_expanded_exprs hiqs in
  let p = invert_negative_term (separate_expanded_expr sod) in
  let q2 = power_of_expanded_expr (expand_and_simplify f_denom) 2 in
  let u_init = u_init vars eps p q2 in
  print_endline ("u_init: " ^ (string_of_float u_init));
  let vars_weight_list = split_vars_with_weight vars num_intervals in
  let u = bin_search_u_weighted vars_weight_list eps p q2 c order (u_init *. 1.01) (u_init *. 20000.) in
  print_endline ("u: " ^ (string_of_float u));

