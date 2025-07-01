type distr = 
| Uniform of float * float
| Normal of float * float
| Exponential of float * float
| Wide of float * float

type vars = (string, distr) Hashtbl.t

let low_of_distr (d : distr) : float = 
  match d with 
  | Uniform (low, _) -> low
  | Normal (low, _) -> low
  | Exponential (low, _) -> low
  | Wide (low, _) -> low 

let high_of_distr (d : distr) : float =
  match d with 
  | Uniform (_, hi) -> hi
  | Normal (_, hi) -> hi
  | Exponential (_, hi) -> hi
  | Wide (_, hi) -> hi

type expr = 
| Const of float 
| Var of string
| Add of expr * expr 
| Min of expr * expr 
| Mul of expr * expr 
| Div of expr * expr
(* the following constructors only to be used internally *)
| Evar of int (* e_i *)
| Dvar of int (* d_i *)
| Exp of expr * int 
| Pvar of string (* x+ *)
| Nvar of string (* x- *)

type rv = 
| Rv of string 
| Prv of string 
| Nrv of string

type term = float * (rv * int) list 
(* A term is a monomial *)

type expanded_expr = term list
(* Expanded expr is a polynomial, sum of terms *)

let rec string_of_distr (d : distr) : string = 
  match d with 
  | Uniform (low, hi) -> "U(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"
  | Normal (low, hi) -> "N(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"
  | Exponential (low, hi) -> "E(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"
  | Wide (low, hi) -> "W(" ^ string_of_float low ^ ", " ^ string_of_float hi ^ ")"

let print_vars (vars : (string, distr) Hashtbl.t) : unit = 
  Hashtbl.iter (fun name d -> 
    Printf.printf "%s: %s\n" name (string_of_distr d)
  ) vars


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
  | Pvar x -> x ^ "+"
  | Nvar x -> x ^ "-"
  | Exp (f, n) -> "(" ^ string_of_expr f ^ ")^" ^ string_of_int n

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

let rv_to_name_no_sign (rv : rv) : string = 
  match rv with 
  | Rv x -> x
  | Prv x -> x
  | Nrv x -> x
  
let rv_to_expr (rv : rv) : expr = 
  match rv with 
  | Rv x -> Var x
  | Prv x -> Pvar x
  | Nrv x -> Nvar x
  
let rvn_to_expr (rv, n) : expr = 
  let rv_expr = rv_to_expr rv in 
  if n = 1 then rv_expr
  else List.fold_left (fun acc _ -> Mul (acc, rv_expr)) rv_expr (List.init (n - 1) (fun _ -> rv_expr))
  
let term_to_expr (t : term) : expr = 
  let (c, rvs) = t in 
  let rvs_expr = List.map rvn_to_expr rvs in
  List.fold_left (fun acc rv_expr -> Mul (acc, rv_expr)) (Const c) rvs_expr
  
let expanded_expr_to_expr (f : expanded_expr) : expr = 
  List.fold_left (fun acc t -> Add (acc, term_to_expr t)) (Const 0.) f

let get_low_high (name : string) (vars : (string, distr) Hashtbl.t) : float * float =
  match Hashtbl.find_opt vars name with
  | Some (Uniform (low, high)) -> (low, high)
  | Some (Normal (low, high)) -> (low, high)
  | Some (Exponential (low, high)) -> (low, high)
  | _ -> failwith ("get_low_high: Unsupported distribution type for " ^ name)
