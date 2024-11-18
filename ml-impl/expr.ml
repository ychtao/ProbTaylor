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

type rv = 
| Rv of string 
| Prv of string 
| Nrv of string

type term = float * (rv * int) list 

type expanded_expr = term list

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

let string_of_rv (rv : rv) : string = 
  match rv with 
  | Rv x -> x
  | Prv x -> x ^ "+"
  | Nrv x -> x ^ "-"

let rec string_of_term (t : term) : string = 
  let (c, rvs) = t in 
  let rvs_str = List.fold_left (fun acc (rv, k) -> 
    let rv_str = string_of_rv rv in
    let power_str = if k = 1 then "" else "^" ^ string_of_int k in
    acc ^ rv_str ^ power_str
  ) "" rvs in 
  string_of_float c ^ "*" ^ rvs_str

let rec string_of_expanded_expr (f : expanded_expr) : string = 
  String.concat " + " (List.map string_of_term f)
