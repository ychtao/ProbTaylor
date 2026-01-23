open Expr
open Ops
open Input_parser
open Printf
open Unix

let rec diff_di (tf : expr) (i : int) : expr = 
  match tf with 
  | Const _ -> Const 0.
  | Var x -> Const 0.
  | Evar k -> Const 0.
  | Dvar k -> if k = i then Const 1. else Const 0.
  | Add (f1, f2) -> Add (diff_di f1 i, diff_di f2 i)
  | Min (f1, f2) -> Min (diff_di f1 i, diff_di f2 i)
  | Mul (f1, f2) -> Add (Mul (diff_di f1 i, f2), Mul (f1, diff_di f2 i))
  | Div (f1, f2) -> Div (Min (Mul (diff_di f1 i, f2), Mul (f1, diff_di f2 i)), Mul (f2, f2))
  | _ -> failwith "Differentiation not supported"

let rec sum_of_di_diffs (tf : expr) (k : int) : expr = 
  if k = 0 then Const 0.
  else let cur = simplify (Mul (set_err_to_zero (diff_di tf k), Dvar k)) in
  Add (cur, sum_of_di_diffs tf (k - 1))

let rec sum_of_di_diffs_expanded (tf : expr) (k : int) : expanded_expr = 
  if k = 0 then []
  else let cur = expand_and_simplify (simplify (Mul (set_err_to_zero (diff_di tf k), Dvar k))) in 
  List.rev_append cur (sum_of_di_diffs_expanded tf (k - 1))

(* let rec sum_of_di_diffs_aux (tf : expr) (i : int) (k : int) : expr = 
  if i = 0 then Const 0.
  else let cur = simplify (Mul (set_err_to_zero (diff_di tf k), Dvar (i))) in
  Add (cur, sum_of_di_diffs_aux tf (i-1) k)

let sum_of_di_diffs (tf : expr) (k : int) : expr =
  sum_of_di_diffs_aux tf k k  *)

let diff_yiyj (tf : expr) (i : int) (j : int) (k : int) : expr =
  let ret' = if i <= k then diff_ei tf i else diff_di tf (i - k) in 
  let ret = if j <= k then diff_ei ret' j else diff_di ret' (j - k) in 
  simplify ret

let rec replace_error_with_ps (f : expr) (k : int) : expr =
  match f with 
  | Evar i -> Var ("p" ^ string_of_int i)
  | Dvar i -> Var ("p" ^ string_of_int (k + i))
  | Add (f1, f2) -> Add (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Min (f1, f2) -> Min (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Mul (f1, f2) -> Mul (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Div (f1, f2) -> Div (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | _ -> f

let yi_to_error (i : int) (k : int) : expr = 
  if i <= k then Evar i else Dvar (i - k)

let sum_of_yiyj_diffs (tf : expr) (k : int) : expr =
  let rec loop i j acc = 
    if i > 2 * k then acc 
    else if j > 2 * k then loop (i + 1) (i + 2) acc 
    else let cur = replace_error_with_ps (diff_yiyj tf i j k) k in 
    let yi = yi_to_error i k in
    let yj = yi_to_error j k in
      loop i (j + 1) (Add (acc, Mul (yi, Mul (yj, cur)))) in 
  let cross_terms = loop 1 2 (Const 0.) in
  let rec loop2 i acc = 
    if i > 2 * k then acc 
    else let cur = replace_error_with_ps (diff_yiyj tf i i k) k in 
    let yi = yi_to_error i k in
      loop2 (i + 1) (Add (acc, Mul (yi, Mul (yi, cur))) ) in
  let diag_terms = loop2 1 (Const 0.) in
  Add (cross_terms, Mul (Const 0.5, diag_terms))

let half_term (c, rvs) : term = 
  (c *. 0.5, rvs)

let cross_terms_expanded (tf : expr) (k : int) : expanded_expr = 
  let rec aux i j acc = 
    if i > 2 * k then acc 
    else if j > 2 * k then aux (i + 1) (i + 2) acc 
    else let cur_coef = replace_error_with_ps (diff_yiyj tf i j k) k in 
    let yi = yi_to_error i k in
    let yj = yi_to_error j k in
    let cur = expand_and_simplify (simplify (Mul (yi, (Mul (yj, cur_coef))))) in 
    aux i (j + 1) (List.rev_append acc cur) in 
  aux 1 2 []

let diag_terms_expanded (tf : expr) (k : int) : expanded_expr =
  let rec aux i acc = 
    if i > 2 * k then acc 
    else let cur_coef = replace_error_with_ps (diff_yiyj tf i i k) k in 
    let yi = yi_to_error i k in 
    let cur = expand_and_simplify (Mul (yi, Mul (yi, cur_coef))) in 
    aux (i + 1) (List.rev_append acc cur) in 
  map_tailrec half_term (aux 1 [])

let sum_of_yiyj_diffs_expanded (tf : expr) (k : int) : expanded_expr = 
  let cterms = cross_terms_expanded tf k in 
  let dterms = cross_terms_expanded tf k in 
  List.rev_append cterms dterms

let error2 (tf : expr) (k : int) : expr = 
  let sod = simplify (sum_of_di_diffs tf k) in
  let sodd = simplify (sum_of_yiyj_diffs tf k) in
  Add (sod, sodd)

let error2_expanded (tf : expr) (k : int) : expanded_expr = 
  let sod = sum_of_di_diffs_expanded tf k in 
  let sodd = sum_of_yiyj_diffs_expanded tf k in 
  List.rev_append sod sodd

(* Suppose oc has been opened *)
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
    | _ -> failwith "Unsupported distribution!"
  ) vars

let bound_error2_gelpia filename eps dlt = 
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let error2 = error2 tf k in 
  let oc = open_out "error2.txt" in 
  print_ed_ranges oc vars k eps dlt;
  fprintf oc "%s\n" (string_of_expr error2);
  close_out oc;
  printf "Calling Gelpia for 2nd order error:\n";
  flush_all ();
  Sys.command ".././gelpia/bin/gelpia error2.txt" 

let get_name_range (vars : vars) (x : string) : float * float = 
  let d = try Hashtbl.find vars x 
    with Not_found -> print_endline x; failwith "variable not found" in 
  (low_of_distr d, high_of_distr d)

let get_rv_range (vars : vars) rv : float * float = 
  let x = rv_to_name_no_sign rv in 
  let d = try Hashtbl.find vars x 
    with Not_found -> print_endline x; failwith "variable not found" in 
  (low_of_distr d, high_of_distr d)

let rv_upper_bound (vars : vars) (rv, n) : float = 
  let (lo, hi) = get_rv_range vars rv in
  let ret = (max (abs_float lo) (abs_float hi)) ** (float_of_int n) in 
  ret 

let term_upper_bound (vars : vars) (c, rvs) : float = 
  let rv_bounds = map_tailrec (fun rv -> rv_upper_bound vars rv) rvs in 
  let ret = (abs_float c) *. (List.fold_left ( *. ) 1. rv_bounds) in
  (* printf "%s : %e\n" (string_of_term (c, rvs)) ret;  *)
  ret

let expanded_expr_upper_bound (vars : vars) (f : expanded_expr) : float = 
  let term_bounds = map_tailrec (fun t -> term_upper_bound vars t) f in 
  List.fold_left ( +. ) 0.0 term_bounds

let add_ed_ranges_to_vars (vars : vars) (k : int) eps dlt : unit = 
  let rec loop_e k i = 
    if i > k then ()
    else (Hashtbl.add vars ("e" ^ (string_of_int i)) (Uniform (-. eps, eps));
    loop_e k (i + 1)) in 
  loop_e k 1;
  let rec loop_d k i = 
    if i > k then () 
    else (Hashtbl.add vars ("d" ^ (string_of_int i)) (Uniform (-. dlt, dlt));
    loop_d k (i + 1)) in 
  loop_d k 1;
  let rec loop_p k i = 
    if i > 2 * k then ()
    else if i <= k then (Hashtbl.add vars ("p" ^ (string_of_int i)) (Uniform (-. eps, eps)); loop_p k (i + 1))
    else (Hashtbl.add vars ("p" ^ (string_of_int i)) (Uniform (-. dlt, dlt));
    loop_p k (i + 1))
  in loop_p k 1

let rec bf_max_of_expr (vars : vars) (f : expr) eps dlt : float = 
  match f with 
  | Const c -> abs_float c
  | Var x -> let (lo, hi) = get_name_range vars x in (max (abs_float lo) (abs_float hi))
  | Add (f1, f2) -> 
    let max1 = bf_max_of_expr vars f1 eps dlt in 
    let max2 = bf_max_of_expr vars f2 eps dlt in 
    max1 +. max2 
  | Min (f1, f2) ->
    let max1 = bf_max_of_expr vars f1 eps dlt in 
    let max2 = bf_max_of_expr vars f2 eps dlt in 
    max1 +. max2 
  | Mul (f1, f2) ->
    let max1 = bf_max_of_expr vars f1 eps dlt in 
    let max2 = bf_max_of_expr vars f2 eps dlt in 
    max1 *. max2 
  | Div (f1, (Const c)) -> 
    let max1 = bf_max_of_expr vars f1 eps dlt in 
    abs_float (max1 *. c)
  | Evar i -> eps
  | Dvar i -> dlt 
  | Div (f1, f2) -> 
    let max1 = bf_max_of_expr vars f1 eps dlt in 
    let max2 = bf_max_of_expr vars f2 eps dlt in 
    max1 /. max2
  | _ -> failwith "max_of_expr: not implemented"

    
let bound_error2_tri filename eps dlt : unit = 
  printf "Bounding second order error...\n"; flush_all ();
  let (vars, f) = process_input filename in 
  let (tf, k) = tilde f in 
  let error2 = error2 tf k in 
  (* printf "%s\n" (string_of_expr error2); flush_all (); *)
  add_ed_ranges_to_vars vars k eps dlt; 
  printf "Upper bound of error2: %e\n" (bf_max_of_expr vars error2 eps dlt); 
  flush_all()

  (* let error2 = error2_expanded tf k in 
  printf "error2 expanded\n"; flush_all ();
  (* let error2 = expand_and_simplify error2 in *)
  add_ed_ranges_to_vars vars k eps dlt;
  printf "Upper bound of error2: %e\n" (expanded_expr_upper_bound vars error2) *)


