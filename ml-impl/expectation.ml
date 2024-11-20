open Expr
open Printf

let uniform_nth_moment (n : int) (low : float) (high : float) : float =  
  (* (high^(n+1) - low^(n+1)) / ((n+1) * (high-low)) *)
  let num = (high ** (float_of_int (n + 1))) -. (low ** (float_of_int (n + 1))) in
  let den = (float_of_int (n + 1)) *. (high -. low) in
  num /. den

let uniform_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  if low >= 0. then uniform_nth_moment n low high
  else if high <= 0. then 0.
  else let num = (high ** (float_of_int (n + 1))) in
       let den = (float_of_int (n + 1)) *. (high -. low) in
       num /. den

let uniform_nth_moment_neg (n : int) (low : float) (high : float) : float = 
  if high <= 0. then -. (uniform_nth_moment n low high)
  else if low >= 0. then 0.
  else let num = ((-. low) ** (float_of_int (n + 1))) in
       let den = (float_of_int (n + 1)) *. (high -. low) in
       num /. den

let uniform_expectation_of_name (n : int) (pos : int) (neg : int) (low : float) (high : float) : float = 
  if (pos > 0 && neg > 0) then 0.
  else if (pos = 0 && neg = 0) then uniform_nth_moment n low high 
  else if (pos = 0) then (-1. ** (float_of_int n)) *. (uniform_nth_moment_neg (n + neg) low high)
  else if (neg = 0) then uniform_nth_moment_pos (n + pos) low high 
  else failwith "Unexpected case"

let uniform_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) : float = 
  let (rv, n) = rv in 
  match rv with 
  | Rv x -> uniform_nth_moment n low high
  | Prv x -> uniform_nth_moment_pos n low high
  | Nrv x -> uniform_nth_moment_neg n low high

let uniform_expectation_of_two_rvs (rv1 : (rv * int)) (rv2 : (rv * int)) (low : float) (high : float) : float = 
  let (rv1, n1) = rv1 in
  let (rv2, n2) = rv2 in
  match (rv1, rv2) with
  | (Rv _, Rv _) -> uniform_nth_moment (n1 + n2) low high
  | (Rv _, Prv _) -> uniform_nth_moment_pos (n1 + n2) low high 
  | (Rv _, Nrv _) -> (-1. ** (float_of_int n1)) *. (uniform_nth_moment_neg (n1 + n2) low high)
  | (Prv _, Rv _) -> uniform_nth_moment_pos (n1 + n2) low high
  | (Prv _, Prv _) -> uniform_nth_moment_pos (n1 + n2) low high
  | (Prv _, Nrv _) -> 0.
  | (Nrv _, Rv _) -> (-1. ** (float_of_int n2)) *. (uniform_nth_moment_neg (n1 + n2) low high)
  | (Nrv _, Prv _) -> 0.
  | (Nrv _, Nrv _) -> uniform_nth_moment_neg (n1 + n2) low high

let match_first_name (name : string) (rvs : (rv * int) list) : ((rv * int) * ((rv * int) list)) option =
  match rvs with 
  | [] -> None 
  | (rv, n) :: rest -> if (rv_to_name_no_sign rv) = name then Some ((rv, n), rest) else None

let rec expectation_of_rvs (rvs : (rv * int) list) (vars : (string, distr) Hashtbl.t) : float = 
  match rvs with 
  | [] -> 1. 
  | (rv, n) :: rest -> 
    let name = rv_to_name_no_sign rv in 
    let match_result = match_first_name name rest in
    (match match_result with
    | None -> let d = Hashtbl.find vars name in
      (match d with 
      | Uniform (low, high) -> (uniform_expectation_of_one_rv (rv, n) low high) *. (expectation_of_rvs rest vars)
      | _ -> failwith "Not supported")
    | Some ((rv', n'), rest') -> let d = Hashtbl.find vars name in 
      (match d with 
      | Uniform (low, high) -> (uniform_expectation_of_two_rvs (rv, n) (rv', n') low high) *. (expectation_of_rvs rest' vars)
      | _ -> failwith "Not supported"))

let expectation_of_term (t : term) (vars : (string, distr) Hashtbl.t) : float = 
  let (c, rvs) = t in 
  c *. (expectation_of_rvs rvs vars)

let expectation_of_expanded_expr (f : expanded_expr) (vars : (string, distr) Hashtbl.t) : float = 
  List.fold_left (fun acc t -> acc +. (expectation_of_term t vars)) 0. f


