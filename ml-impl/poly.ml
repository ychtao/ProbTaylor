open Expr
open Input_parser
open Printf
open Ops
open Expectation
open Partition
open Error2
open Unix

let u_old vars eps pn c order : float = 
  let rcd = Hashtbl.create 20 in 
  let epn = fst (expectation_of_expanded_expr pn vars rcd) in 
  let u_old = eps *. (epn /. (1. -. c)) ** (1. /. (float_of_int order)) in 
  u_old

let u_init vars eps p c : float = 
  let rcd = Hashtbl.create 20 in 
  let ep = fst (expectation_of_expanded_expr p vars rcd) in 
  let u_init = eps *. ep in 
  u_init

(* order must be even *)
let u_flag_float_sub vars rcd eps p u order : float = 
  let k_u = add_expanded_exprs (const_times_expanded_expr eps p) (const_expanded_expr (-. u)) in 
  let mu = fst (expectation_of_expanded_expr k_u vars rcd) in
  (* flag_float_num = (Ku - mu)^order *)
  let flag_float_num = simplify_expanded_expr (power_of_expanded_expr 
    (add_expanded_exprs k_u (const_expanded_expr (-. mu))) order) in
  let flag_float = fst (expectation_of_expanded_expr flag_float_num vars rcd) /. (mu ** (float_of_int order)) in 
  if flag_float > 1. then 1. else flag_float

let u_flag_float_weighted vars_weight_list rcd eps p u order : float = 
  let sum = List.fold_left (fun acc (vars, weight) ->
    let cur = u_flag_float_sub vars rcd eps p u order in 
    (* printf "cur: %e\n" cur; *)
    acc +. (cur *. weight)) 0. vars_weight_list in 
  sum 

let rec bin_search_u_weighted vars_weight_list rcd eps p c order left right : float = 
  printf "Left: %e, Right: %e\n" left right;
  let mid = (left *. right) ** 0.5 in 
  let flag_float = u_flag_float_weighted vars_weight_list rcd eps p mid order in 
  printf "Mid: %e, Flag Float: %e\n" mid flag_float;
  print_endline "";
  if flag_float > 1. -. c then bin_search_u_weighted vars_weight_list rcd eps p c order mid right
  else if (right /. left) < 1.1 then mid 
  else bin_search_u_weighted vars_weight_list rcd eps p c order left mid

let get_order_arg () =
  let default_order = 2 in
  let order = ref default_order in
  let argv = Array.to_list Sys.argv in
  let rec parse = function
    | "--order" :: v :: _ -> (try order := int_of_string v with _ -> ()); ()
    | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !order

let get_num_intervals_arg () =
  let default_num = 32 in
  let num_intervals = ref default_num in
  let argv = Array.to_list Sys.argv in
  let rec parse = function
    | "--num" :: v :: _ -> (try num_intervals := int_of_string v with _ -> ()); ()
    | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !num_intervals

let get_nm_flag () = 
  Array.exists (fun arg -> arg = "--nm") Sys.argv

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let num_intervals = get_num_intervals_arg () in 
  let order = get_order_arg () in 
  let rcd = Hashtbl.create 20 in 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let sod = sum_of_expanded_exprs (List.map expand_and_simplify (list_of_ei_diffs tf k)) in
  let p = simplify_expanded_expr (invert_negative_term (separate_expanded_expr_opt sod vars)) in 
  printf "p\n";
  let pn = power_of_expanded_expr p order in 
  printf "pn\n";
  let u_old = u_old vars eps pn c order in 
  if get_nm_flag() then printf "order = %d, u = %e" order u_old else
  let u_init = u_init vars eps p c in 
  printf "u_init: %e\n" u_init; 
  printf "u_old: %e\n" u_old;
  let vars_weight_list = split_vars_with_weight vars num_intervals in 
  let u = bin_search_u_weighted vars_weight_list rcd eps p c order (u_init *. 1.01) (u_old *. 1.01) in 
  printf "%s\n" filename;
  printf "u: %e\n" u;
  printf "order = %d, num_intervals = %d\n" order num_intervals
  




(* let bound1_poly filename eps c order = 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  (* print_endline ("tf: " ^ (string_of_expr tf)); *)
  let sod = simplify (sum_of_ei_diffs tf k) in
  (* print_endline ("sod: " ^ (string_of_expr sod)); *)
  let p = invert_negative_term (separate_expanded_expr_opt (expand_and_simplify sod) vars) in
  (* print_endline ("p: " ^ (string_of_expanded_expr p)); *)
  let pn = power_of_expanded_expr p order in
  (* print_endline ("pn: " ^ (string_of_expanded_expr pn)); *)
  let esod = expectation_of_expanded_expr pn vars in
  (* print_endline ("esod: " ^ (string_of_float esod)); *)
  let bound = eps *. ((esod /. (1. -. c)) ** (1. /. (float_of_int order))) in
  bound

let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in 
  let c = 0.99 in 
  let order = 2 in 
  let start_time = Unix.gettimeofday () in
  let bound = bound1_poly filename eps c order in 
  print_endline ("First order error bound = " ^ (string_of_float bound));
  let elapsed_time = Unix.gettimeofday () -. start_time in
  print_endline ("Elapsed time = " ^ (string_of_float elapsed_time) ^ " seconds") *)


(* The following code tries all even orders between 2 and 30 and gives the optimal threshold *)
(* The following code does not use interval partition or binary search *)
(* let _ = 
  let filename = Sys.argv.(1) in 
  let eps = 2. ** (-24.) in
  let c = 0.99 in
  let start_time = Unix.gettimeofday () in
  let rec find_best_bound best_bound best_order order = 
    if order > 30 then (best_bound, best_order)
    else try  
      let bound = bound1_poly filename eps c order in 
      if bound < best_bound then find_best_bound bound order (order + 2)
      else find_best_bound best_bound best_order (order + 2)
    with 
      | Stack_overflow -> (best_bound, best_order)
  in 
  let initial_bound = try bound1_poly filename eps c 2 with Stack_overflow -> infinity in 
  let (best_bound, best_order) = find_best_bound initial_bound 2 4 in
  print_endline ("First order error bound = " ^ (string_of_float best_bound));
  print_endline ("Corresponding analysis order = " ^ (string_of_int best_order));
  let elapsed_time = Unix.gettimeofday () -. start_time in
  print_endline ("Elapsed time = " ^ (string_of_float elapsed_time) ^ " seconds") *)

(* Suppose oc has already been open *)
let print_ed_ranges oc vars k eps dlt = 
  let rec loop_e k i = 
    if i > k then ()
    (* else (fprintf oc "e%d:(-%e, %e)\n" i eps eps; loop_e k (i + 1)) in *)
    else (fprintf oc "[-%e, %e] e%d;\n" eps eps i; loop_e k (i + 1)) in
  loop_e k 1;
  let rec loop_d k i = 
    if i > k then ()
    (* else (fprintf oc "d%d:(-%e, %e)\n" i dlt dlt; loop_d k (i + 1)) in *)
    else (fprintf oc "[-%e, %e] d%d;\n" dlt dlt i; loop_d k (i + 1)) in 
  loop_d k 1;
  let rec loop_p k i = 
    if i > 2 * k then ()
    (* else if i <= k then (fprintf oc "p%d:(-%e, %e)\n" i eps eps; loop_p k (i + 1)) *)
    else if i <= k then (fprintf oc "[-%e, %e] p%d;\n" eps eps i; loop_p k (i + 1)) 
    (* else (fprintf oc "p%d:(-%e, %e)\n" i dlt dlt; loop_p k (i + 1)) in *)
    else (fprintf oc "[-%e, %e] p%d;\n" dlt dlt i; loop_p k (i + 1)) in 
  loop_p k 1;
  Hashtbl.iter (fun var distr -> 
    match distr with 
    | Uniform (low, hi) -> fprintf oc "[%e, %e] %s;\n" low hi var
    | Normal (low, hi) -> fprintf oc "[%e, %e] %s;\n" low hi var
    | Exponential (low, hi) -> fprintf oc "[%e, %e] %s;\n" low hi var
    | _ -> failwith ("print_ed_ranges: Unsupported distribution type for variable ")
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
  (* print_endline (string_of_expr tf); *)
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

