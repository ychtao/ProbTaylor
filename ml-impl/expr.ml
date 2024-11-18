type distr = 
| Uniform of float * float
| Normal of float * float
| Exponential of float * float

type expr = 
| Const of float 
| Var of string
| Evar of int
| Dvar of int
| Add of expr * expr 
| Min of expr * expr 
| Mul of expr * expr 
| Div of expr * expr

let rec string_of_distr (d : distr) : string = 
  match d with 
  | Uniform (low, hi) -> "U(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"
  | Normal (low, hi) -> "N(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"
  | Exponential (low, hi) -> "E(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"

let rec string_of_expr (f : expr) : string = 
  match f with 
  | Const c -> string_of_float c
  | Var x -> x
  | Evar k -> "e" ^ string_of_int k
  | Dvar k -> "d" ^ string_of_int k
  | Add (f1, f2) -> "(" ^ string_of_expr f1 ^ " + " ^ string_of_expr f2 ^ ")"
  | Min (f1, f2) -> "(" ^ string_of_expr f1 ^ " - " ^ string_of_expr f2 ^ ")"
  | Mul (f1, f2) -> "(" ^ string_of_expr f1 ^ " * " ^ string_of_expr f2 ^ ")"
  | Div (f1, f2) -> "(" ^ string_of_expr f1 ^ " / " ^ string_of_expr f2 ^ ")"