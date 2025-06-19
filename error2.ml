open Expr
open Ops

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

let error2 (tf : expr) (k : int) : expr = 
  let sod = simplify (sum_of_di_diffs tf k) in
  let sodd = simplify (sum_of_yiyj_diffs tf k) in
  Add (sod, sodd)

