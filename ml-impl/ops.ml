open Expr
open Printf

let rv_to_name_no_sign (rv : rv) : string = 
  match rv with 
  | Rv x -> x
  | Prv x -> x
  | Nrv x -> x

let rec tilde_aux (f : expr) (k0 : int) : expr * int =
  match f with
  | Const c -> (Const c, k0)
  | Var x -> (Var x, k0)
  | Add (f1, f2) ->
    let (f1', k1) = tilde_aux f1 k0 in 
    let (f2', k2) = tilde_aux f2 k1 in 
    let k = k2 + 1 in 
    let ek = Evar k in
    let dk = Dvar k in
    Add (Mul (Add (f1', f2'), (Add (Const 1., ek))), dk), k
  | Min (f1, f2) ->
    let (f1', k1) = tilde_aux f1 k0 in 
    let (f2', k2) = tilde_aux f2 k1 in 
    let k = k2 + 1 in 
    let ek = Evar k in
    let dk = Dvar k in
    Add (Mul (Min (f1', f2'), (Add (Const 1., ek))), dk), k
  | Mul (f1, f2) ->
    let (f1', k1) = tilde_aux f1 k0 in 
    let (f2', k2) = tilde_aux f2 k1 in 
    let k = k2 + 1 in 
    let ek = Evar k in
    let dk = Dvar k in
    Add (Mul (Mul (f1', f2'), (Add (Const 1., ek))), dk), k
  | Div (f1, f2) ->
    let (f1', k1) = tilde_aux f1 k0 in 
    let (f2', k2) = tilde_aux f2 k1 in 
    let k = k2 + 1 in 
    let ek = Evar k in
    let dk = Dvar k in
    Add (Mul (Div (f1', f2'), (Add (Const 1., ek))), dk), k
  | _ -> failwith "Computation of tilde f failed"

let tilde (f : expr) : expr * int = tilde_aux f 0

let rec set_err_to_zero (f : expr) : expr =
  match f with 
  | Evar k -> Const 0.
  | Dvar k -> Const 0.
  | Add (f1, f2) -> Add (set_err_to_zero f1, set_err_to_zero f2)
  | Min (f1, f2) -> Min (set_err_to_zero f1, set_err_to_zero f2)
  | Mul (f1, f2) -> Mul (set_err_to_zero f1, set_err_to_zero f2)
  | Div (f1, f2) -> Div (set_err_to_zero f1, set_err_to_zero f2)
  | _ -> f

let rec simplify_aux (f : expr) : expr =
  match f with 
  | Add (f1, Const 0.) -> simplify_aux f1
  | Add (Const 0., f2) -> simplify_aux f2
  | Add (Const x, Const y) -> Const (x +. y)
  | Min (f1, Const 0.) -> simplify_aux f1
  | Min (Const 0., f2) -> simplify_aux f2
  | Min (Const x, Const y) -> Const (x -. y)
  | Mul (f1, Const 0.) -> Const 0.
  | Mul (Const 0., f2) -> Const 0.
  | Mul (f1, Const 1.) -> simplify_aux f1
  | Mul (Const 1., f2) -> simplify_aux f2
  | Mul (Const x, Const y) -> Const (x *. y)
  (* | Div (f1, Const 0.) -> Const 0. *)
  | Div (Const 0., f2) -> Const 0.
  | Div (f1, Const 1.) -> simplify_aux f1
  | Div (f1, f2) when f1 = f2 -> Const 1.
  | Div (Const x, Const y) -> Const (x /. y)
  | Div (f1, Const y) -> Mul (Const (1. /. y), simplify_aux f1)
  | Add (f1, f2) -> Add (simplify_aux f1, simplify_aux f2)
  | Min (f1, f2) -> Min (simplify_aux f1, simplify_aux f2)
  | Mul (f1, f2) -> Mul (simplify_aux f1, simplify_aux f2)
  | Div (f1, f2) -> Div (simplify_aux f1, simplify_aux f2)
  | _ -> f

(* iteratively apply simplify_aux to an expression until no change *)
let rec simplify (f : expr) : expr =
  let f' = simplify_aux f in 
  if f = f' then f else simplify f'

let rec diff_ei (tf : expr) (i : int) : expr = 
  match tf with 
  | Const c -> Const 0.
  | Var x -> Const 0.
  | Evar k -> if k = i then Const 1. else Const 0.
  | Dvar k -> Const 0.
  | Add (f1, f2) -> Add (diff_ei f1 i, diff_ei f2 i)
  | Min (f1, f2) -> Min (diff_ei f1 i, diff_ei f2 i)
  | Mul (f1, f2) -> Add (Mul (diff_ei f1 i, f2), Mul (f1, diff_ei f2 i))
  | Div (f1, f2) -> Div (Min (Mul (diff_ei f1 i, f2), Mul (f1, diff_ei f2 i)), Mul (f2, f2))
  | _ -> failwith "Not supported"

let rec sum_of_ei_diffs (tf : expr) (k : int) : expr =
  if k = 0 then Const 0.
  else Add (simplify (set_err_to_zero (diff_ei tf k)), sum_of_ei_diffs tf (k - 1))

(* assume no error variables or division *)
let rec expand_expr (f : expr) : expanded_expr = 
  match f with 
  | Const c -> [(c, [])]
  | Var x -> [(1.0, [(Rv x, 1)])]
  | Add (f1, f2) -> (expand_expr f1) @ (expand_expr f2)
  | Min (f1, f2) -> (expand_expr f1) @ (List.map (fun (c, vars) -> (-.c, vars)) (expand_expr f2))
  | Mul (f1, f2) ->
    let terms1 = expand_expr f1 in
    let terms2 = expand_expr f2 in
    List.flatten (List.map (fun (c1, vars1) ->
      List.map (fun (c2, vars2) ->
        (c1 *. c2, vars1 @ vars2)
      ) terms2
    ) terms1)
  | Pvar x -> [(1.0, [(Prv x, 1)])]
  | Nvar x -> [(1.0, [(Nrv x, 1)])]
  | Exp (Var x, n) -> [(1.0, [(Rv x, n)])]
  | Exp (Pvar x, n) -> [(1.0, [(Prv x, n)])]
  | Exp (Nvar x, n) -> [(1.0, [(Nrv x, n)])]
  | _ -> failwith "Not supported"

(* Normalize a term - combine same variables, sort in alphabetical order *)
let normalize_term (c, vars) =
  let combine_vars vars =
    let tbl = Hashtbl.create 10 in
    List.iter (fun (v, e) ->
      let current_exp = try Hashtbl.find tbl v with Not_found -> 0 in
      Hashtbl.replace tbl v (current_exp + e)
    ) vars;
    Hashtbl.fold (fun v e acc -> (v, e) :: acc) tbl []
  in
  let compare_vars (v1, _) (v2, _) = 
    let cmp = String.compare (rv_to_name_no_sign v1) (rv_to_name_no_sign v2) in
    if cmp <> 0 then cmp else match (v1, v2) with
    | (Rv _, Rv _) -> 0
    | (Rv _, _) -> -1
    | (_, Rv _) -> 1
    | (Prv _, Prv _) -> 0
    | (Prv _, _) -> -1
    | (_, Prv _) -> 1
    | (Nrv _, Nrv _) -> 0
  in
  let combined_vars = combine_vars vars in
  let sorted_vars = List.sort compare_vars combined_vars in
  (c, sorted_vars)

(* Normalize an expanded expression *)
let normalize_expanded_expr (f : expanded_expr) : expanded_expr =
  List.map normalize_term f

(* Merge similar terms*)
let merge_terms (f : expanded_expr) : expanded_expr = 
  let tbl = Hashtbl.create 20 in
  List.iter (fun (c, vars) ->
    let current_c = try Hashtbl.find tbl vars with Not_found -> 0.0 in
    let new_c = current_c +. c in
    Hashtbl.replace tbl vars (new_c)
  ) f;
  Hashtbl.fold (fun vars c acc -> (c, vars) :: acc) tbl []

let eliminate_zero_terms (f : expanded_expr) : expanded_expr =
  List.filter (fun (c, _) -> c <> 0.0) f

let simplify_expanded_expr (f : expanded_expr) : expanded_expr = 
  f |> normalize_expanded_expr |> merge_terms |> eliminate_zero_terms

let expand_and_simplify (f : expr) : expanded_expr = 
  simplify_expanded_expr (expand_expr f)

let separate_term (t : term) : expanded_expr =
  let (c, rvs) = t in 
  let sep_pn_rv (v, n) =
    match v with 
    | Rv v -> if n = 0 then Const 1.
              else if n = 1 then Min (Pvar v, Nvar v)
              else if n mod 2 = 0 then Exp (Var v, n)
              else Mul (Exp (Var v, n-1), Min (Pvar v, Nvar v))
    | _ -> failwith "Already separated"
  in expand_and_simplify (List.fold_left (fun acc rv -> Mul (acc, sep_pn_rv rv)) (Const c) rvs)

let separate_expanded_expr (f : expanded_expr) : expanded_expr = 
  simplify_expanded_expr (List.flatten (List.map separate_term f))

(* assume that rv (not prv or nrv) are all even power *)
let is_positive_term (t : term) : bool = 
  let (c, rvs) = t in 
  let num_of_negs = List.fold_left (fun acc rv -> match rv with 
    | (Nrv _, n) -> if n mod 2 = 1 then acc + 1 else acc
    | (Rv _, n) -> if n mod 2 = 1 then failwith "Not all even power" else acc
    | _ -> acc ) (if c < 0. then 1 else 0) rvs in 
  if num_of_negs mod 2 = 0 then true else false 

let invert_negative_term (f : expanded_expr) : expanded_expr = 
  List.map (fun (c, rvs) -> if is_positive_term (c, rvs) then (c, rvs) else (-.c, rvs)) f
