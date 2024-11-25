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

let rec replace_error_with_ps (f : expr) (k : int) : expr =
  match f with 
  | Evar i -> Var ("p" ^ string_of_int i)
  | Dvar i -> Var ("p" ^ string_of_int (k + i))
  | Add (f1, f2) -> Add (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Min (f1, f2) -> Min (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Mul (f1, f2) -> Mul (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | Div (f1, f2) -> Div (replace_error_with_ps f1 k, replace_error_with_ps f2 k)
  | _ -> f
  

