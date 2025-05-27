open Expr
open Printf

let hashtbl_of_list l =
  let tbl = Hashtbl.create (List.length l) in 
  List.iter (fun (k, v) -> Hashtbl.add tbl k v) l;
  tbl

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
  (* | Min (Const 0., f2) -> simplify_aux f2 *)
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
  | _ -> failwith "Differentiation not supported"

let rec sum_of_ei_diffs (tf : expr) (k : int) : expr =
  if k = 0 then Const 0.
  else Add (simplify (set_err_to_zero (diff_ei tf k)), sum_of_ei_diffs tf (k - 1))

let rec list_of_ei_diffs (tf : expr) (k : int) : expr list = 
  if k = 0 then []
  else (simplify (set_err_to_zero (diff_ei tf k))) :: list_of_ei_diffs tf (k - 1)

(* assume no error variables or division *)
(* must be normalized after expanding *)
let rec expand_expr (f : expr) : expanded_expr = 
  let tappend l1 l2 = List.rev_append (List.rev l1) l2 in 
  match f with 
  | Const 0. -> []
  | Const c -> [(c, [])]
  | Var x -> [(1.0, [(Rv x, 1)])]
  | Add (f1, f2) -> 
    let terms1 = expand_expr f1 in
    let terms2 = expand_expr f2 in 
    tappend terms1 terms2
  | Min (f1, f2) -> 
    let terms1 = expand_expr f1 in
    let terms2 = (List.map (fun (c, vars) -> (-.c, vars)) (expand_expr f2)) in
    tappend terms1 terms2
  | Mul (f1, f2) ->
    let terms1 = expand_expr f1 in
    let terms2 = expand_expr f2 in
    List.flatten (List.map (fun (c1, vars1) ->
      List.map (fun (c2, vars2) ->
        (c1 *. c2, tappend vars1 vars2)
      ) terms2
    ) terms1)
  | Pvar x -> [(1.0, [(Prv x, 1)])]
  | Nvar x -> [(1.0, [(Nrv x, 1)])]
  | Exp (Var x, n) -> [(1.0, [(Rv x, n)])]
  | Exp (Pvar x, n) -> [(1.0, [(Prv x, n)])]
  | Exp (Nvar x, n) -> [(1.0, [(Nrv x, n)])]
  | Div (f1, Const n2) -> expand_expr (Mul ((Const (1. /. n2)), f1))
  | _ -> failwith "Not supported"

(* let tappend (l1 : 'a list) (l2 : 'a list) : 'a list = 
  List.rev_append (List.rev l1) l2

let flatten_add (root : expr) : expr list = 
  let rec loop (stack : expr list) (acc : expr list) = 
    match stack with 
    | [] -> acc 
    | e :: rest -> match e with 
      | Add (e1, e2) -> loop (e1 :: e2 :: rest) acc
      | Min (e1, e2) -> loop (e1 :: (Mul (Const (-1.), e2)) :: rest) acc
      | _ -> loop rest (e :: acc) in 
  List.rev (loop [root] []) 

let multiply_terms (l1 : expanded_expr) (l2 : expanded_expr) : expanded_expr = 
  List.fold_left 
    (fun acc (c1, vars1) -> 
      List.fold_left 
        (fun acc (c2, vars2) -> 
          (c1 *. c2, tappend vars1 vars2) :: acc) 
        acc l2) 
    [] l1

let rec expand_summand (f : expr) : expanded_expr = 
  match f with 
  | Const 0. -> []
  | Const c -> [(c, [])]
  | Var x -> [(1.0, [(Rv x, 1)])]
  | Pvar x -> [(1.0, [(Prv x, 1)])]
  | Nvar x -> [(1.0, [(Nrv x, 1)])]
  | Exp (Var x, n) -> [(1.0, [(Rv x, n)])]
  | Exp (Pvar x, n) -> [(1.0, [(Prv x, n)])]
  | Exp (Nvar x, n) -> [(1.0, [(Nrv x, n)])]
  | Mul (f1, f2) -> 
      let terms1 = expand_summand f1 in 
      let terms2 = expand_summand f2 in
      multiply_terms terms1 terms2
  | Add (f1, f2) -> 
      let terms1 = expand_summand f1 in 
      let terms2 = expand_summand f2 in
      tappend terms1 terms2
  | Min (f1, f2) -> 
      let terms1 = expand_summand f1 in 
      let terms2 = (List.map (fun (c, vars) -> (-.c, vars)) (expand_summand f2)) in
      tappend terms1 terms2
  | _ -> failwith "Not supported"

let expand_expr (f : expr) : expanded_expr = 
  let summands = flatten_add f in
  print_endline (string_of_int (List.length summands));
  print_endline (string_of_expr (List.hd summands));
  List.fold_left (fun acc summand -> let expanded = expand_summand summand in 
    print_endline (string_of_int (List.length expanded));
    tappend acc expanded) [] summands *)

let compare_vars (v1, _) (v2, _) : int = 
  let cmp = String.compare (rv_to_name_no_sign v1) (rv_to_name_no_sign v2) in
  if cmp <> 0 then cmp else match (v1, v2) with
  | (Rv _, Rv _) -> 0 
  | (Rv _, _) -> -1
  | (_, Rv _) -> 1
  | (Prv _, Prv _) -> 0
  | (Prv _, _) -> -1
  | (_, Prv _) -> 1
  | (Nrv _, Nrv _) -> 0

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
  (* let compare_vars (v1, _) (v2, _) = 
    let cmp = String.compare (rv_to_name_no_sign v1) (rv_to_name_no_sign v2) in
    if cmp <> 0 then cmp else match (v1, v2) with
    | (Rv _, Rv _) -> 0
    | (Rv _, _) -> -1
    | (_, Rv _) -> 1
    | (Prv _, Prv _) -> 0
    | (Prv _, _) -> -1
    | (_, Prv _) -> 1
    | (Nrv _, Nrv _) -> 0
  in *)
  let combined_vars = combine_vars vars in
  let sorted_vars = List.sort compare_vars combined_vars in
  (c, sorted_vars)

(* Normalize an expanded expression *)
let normalize_expanded_expr (f : expanded_expr) : expanded_expr =
  List.map normalize_term f

(* Merge similar terms*)
let merge_terms (f : expanded_expr) : expanded_expr = 
  let tbl = Hashtbl.create 200 in
  List.iter (fun (c, vars) ->
    let current_c = try Hashtbl.find tbl vars with Not_found -> 0.0 in
    let new_c = current_c +. c in
    Hashtbl.replace tbl vars (new_c)
  ) f;
  Hashtbl.fold (fun vars c acc -> (c, vars) :: acc) tbl []

let coef_of_term (t : term) : float = 
  let (c, _) = t in c

let rec is_zero_rvs (rvs : (rv * int) list) : bool =
  match rvs with 
  | (rv1, n1) :: (rv2, n2) :: rest -> (match rv1, rv2 with 
    | (Prv name1, Nrv name2) -> 
      if name1 = name2 then true else is_zero_rvs ((rv2, n2) :: rest)
    | (Nrv name1, Prv name2) -> 
      if name1 = name2 then true else is_zero_rvs ((rv2, n2) :: rest)
    | _ -> is_zero_rvs ((rv2, n2) :: rest))
  | _ -> false 

let is_zero_term (t : term) : bool =
  let (c, rvs) = t in c = 0.0 || is_zero_rvs rvs

let eliminate_zero_terms (f : expanded_expr) : expanded_expr =
  List.filter (fun t -> not (is_zero_term t)) f

let simplify_expanded_expr (f : expanded_expr) : expanded_expr = 
  f |> normalize_expanded_expr |> merge_terms |> eliminate_zero_terms

(* Useful definition *)
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
  (* simplify_expanded_expr (List.flatten (List.map separate_term f)) *)
  (List.flatten (List.map separate_term f))

(* assume that rv (not prv or nrv) are all even power *)
(* let is_positive_term (t : term) : bool = 
  let (c, rvs) = t in 
  let num_of_negs = List.fold_left (fun acc rv -> match rv with 
    | (Nrv _, n) -> if n mod 2 = 1 then acc + 1 else acc
    | (Rv _, n) -> if n mod 2 = 1 then failwith "Not all even power" else acc
    | _ -> acc ) (if c < 0. then 1 else 0) rvs in 
  if num_of_negs mod 2 = 0 then true else false  *)

(* let invert_negative_term (f : expanded_expr) : expanded_expr = 
  List.map (fun (c, rvs) -> if is_positive_term (c, rvs) then (c, rvs) else (-.c, rvs)) f *)

let invert_negative_term (f : expanded_expr) : expanded_expr = 
  List.map (fun (c, rvs) -> if c >= 0. then (c, rvs) else (-. c, rvs)) f

let product_of_expanded_expr (f1 : expanded_expr) (f2 : expanded_expr) : expanded_expr = 
  let f1' = expanded_expr_to_expr f1 in 
  let f2' = expanded_expr_to_expr f2 in 
  expand_and_simplify (Mul (f1', f2'))

let rec merge_rv_list_aux acc rvs1 rvs2 = 
  match rvs1, rvs2 with 
  | [], rvs | rvs, [] -> List.rev_append acc rvs
  | (rv1, n1) :: rest1, (rv2, n2) :: rest2 -> 
    let cmp = compare_vars (rv1, n1) (rv2, n2) in 
    if cmp = 0 then 
      if n1 + n2 = 0 then merge_rv_list_aux acc rest1 rest2
      else merge_rv_list_aux ((rv1, n1 + n2) :: acc) rest1 rest2
    else if cmp < 0 then merge_rv_list_aux ((rv1, n1) :: acc) rest1 rvs2
    else merge_rv_list_aux ((rv2, n2) :: acc) rvs1 rest2

let merge_rv_list rvs1 rvs2 : (rv * int) list =
  merge_rv_list_aux [] rvs1 rvs2

let product_of_terms (t1 : term) (t2 : term) : term = 
  let (c1, rvs1) = t1 in 
  let (c2, rvs2) = t2 in 
  normalize_term (c1 *. c2, merge_rv_list rvs1 rvs2)

(* let product_of_expanded_expr (f1 : expanded_expr) (f2 : expanded_expr) : expanded_expr =
  let terms = List.concat (List.map (fun t1 -> 
    List.map (fun t2 -> product_of_terms t1 t2) f2) f1) in
  simplify_expanded_expr terms *)

let product_of_expanded_expr (f1 : expanded_expr) (f2 : expanded_expr) : expanded_expr = 
  let rec aux acc f1_terms = 
    match f1_terms with 
    | [] -> acc 
    | t1 :: rest1 -> 
      let rec aux2 acc2 f2_terms = 
        match f2_terms with 
        | [] -> acc2 
        | t2 :: rest2 -> let new_term = product_of_terms t1 t2 in 
          (* for debugging *)
          (* (if Float.is_nan (coef_of_term new_term) then 
            (printf "t1: %s\n" (string_of_term t1);
            printf "t2: %s\n" (string_of_term t2);
            printf "new_term: %s\n\n" (string_of_term new_term))); *)
          (* end debugging *)
          aux2 (new_term :: acc2) rest2
      in let new_acc = aux2 acc f2 in 
      aux new_acc rest1 in
    simplify_expanded_expr (aux [] f1)

let power_of_expanded_expr (f : expanded_expr) (n : int) : expanded_expr = 
  let rec aux f n acc = 
    if n = 0 then acc 
    else let new_acc = product_of_expanded_expr acc f in 
    aux f (n - 1) new_acc in
  aux f n (expand_and_simplify (Const 1.0))

(* let sum_of_expanded_exprs (ees : expanded_expr list) : expanded_expr = 
  simplify_expanded_expr (List.flatten ees) *)

let sum_of_expanded_exprs (ees : expanded_expr list) : expanded_expr = 
  (List.flatten ees)

let add_expanded_exprs (f1 : expanded_expr) (f2 : expanded_expr) : expanded_expr = 
  simplify_expanded_expr (List.rev_append f1 f2)

let const_expanded_expr (c : float) : expanded_expr = 
  [(c, [])]

let const_times_term (c : float) (t : term) : term = 
  let (c', rvs) = t in 
  (c *. c', rvs)

let const_times_expanded_expr (c : float) (f : expanded_expr) : expanded_expr = 
  List.map (fun t -> const_times_term c t) f

(* let power_of_expanded_expr (f : expanded_expr) (n : int) : expanded_expr = 
  let rec aux f n acc = 
    if n = 0 then acc 
    else if n mod 2 = 1 then aux (product_of_expanded_expr f f) (n / 2) (product_of_expanded_expr acc f)
    else aux (product_of_expanded_expr f f) (n / 2) acc
  in aux f n (expand_and_simplify (Const 1.0)) *)

(* let power_of_expanded_expr_aux (f : expanded_expr) (n : int) : expanded_expr = 
  if n = 1 then f else 
  let f = expanded_expr_to_expr f in 
  let f' = List.fold_left (fun acc _ -> Mul (acc, f)) f (List.init (n - 1) (fun _ -> f)) in
  expand_and_simplify f'

let rec power_of_expanded_expr (f : expanded_expr) (n : int) : expanded_expr =
  print_endline (string_of_int n);
  if n = 1 then f 
  else if n mod 2 = 0 then 
    let f' = power_of_expanded_expr f (n / 2) in
    product_of_expanded_expr f' f'
  else if n mod 3 = 0 then 
    let f' = power_of_expanded_expr f (n / 3) in
    let f'' = product_of_expanded_expr f' f' in
    product_of_expanded_expr f'' f'
  else if n = 5 then 
    let f1 = power_of_expanded_expr_aux f 3 in
    let f2 = power_of_expanded_expr_aux f 2 in
    product_of_expanded_expr f1 f2
  else if n = 7 then 
    let f1 = power_of_expanded_expr f 3 in
    let f2 = power_of_expanded_expr f 4 in
    product_of_expanded_expr f1 f2
  else 
    power_of_expanded_expr_aux f n *)