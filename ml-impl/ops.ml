open Expr

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

let rec simpl_zero_aux (f : expr) : expr =
  match f with 
  | Add (f1, Const 0.) -> simpl_zero_aux f1
  | Add (Const 0., f2) -> simpl_zero_aux f2
  | Min (f1, Const 0.) -> simpl_zero_aux f1
  | Min (Const 0., f2) -> simpl_zero_aux f2
  | Mul (f1, Const 0.) -> Const 0.
  | Mul (Const 0., f2) -> Const 0.
  | Mul (f1, Const 1.) -> simpl_zero_aux f1
  | Mul (Const 1., f2) -> simpl_zero_aux f2
  (* | Div (f1, Const 0.) -> Const 0. *)
  | Div (Const 0., f2) -> Const 0.
  | Div (f1, Const 1.) -> simpl_zero_aux f1
  | Div (f1, f2) when f1 = f2 -> Const 1.
  | Add (f1, f2) -> Add (simpl_zero_aux f1, simpl_zero_aux f2)
  | Min (f1, f2) -> Min (simpl_zero_aux f1, simpl_zero_aux f2)
  | Mul (f1, f2) -> Mul (simpl_zero_aux f1, simpl_zero_aux f2)
  | Div (f1, f2) -> Div (simpl_zero_aux f1, simpl_zero_aux f2)
  | _ -> f

(* iteratively apply simpl_zero to an expression until no change *)
let rec simpl_zero (f : expr) : expr =
  let f' = simpl_zero_aux f in 
  if f = f' then f else simpl_zero f'

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