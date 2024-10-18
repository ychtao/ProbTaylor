type expr = 
| Const of float 
| Var of string
| Evar of int
| Dvar of int
| Add of expr * expr 
| Min of expr * expr 
| Mul of expr * expr 
| Div of expr * expr

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
  | _ -> failwith "impossible"

let tilde (f : expr) : expr * int = tilde_aux f 0

let _ = 
  let f = Div ((Add ((Mul (Var "x", Var "x")), Var "y"), (Add (Var "y", Var "z")))) in
  (* let f = Div (Var "x", (Add (Var "x", Var "y"))) in *)
  let (tf, k) = tilde f in
  let oc = open_out "tilde.txt" in 
  print_endline(string_of_expr f);
  Printf.fprintf oc "%s\n" (string_of_expr tf);  
  Printf.fprintf oc "%s\n" (string_of_int k);
  close_out oc  