open Expr
open Printf
open Owl_maths_quadrature

let param_n = 20

let param_eps = 1e-6

let num_itg = trapz ~n:param_n ~eps:param_eps

(* All functions are based on the assumption that low < high *)

let uniform_pdf (low : float) (high : float) =
  fun x -> 1. /. (high -. low)

let standard_normal_pdf (x : float) : float = 
  1. /. (sqrt (2. *. Float.pi)) *. (exp (-0.5 *. x *. x))

(* let standard_normal_cdf (x : float) : float = 
  let f = standard_normal_pdf in
  let low = -10000.0 in (* A sufficiently low value to approximate -inf *)
  num_itg f low x *)

let erf x =
  let t = 1.0 /. (1.0 +. 0.5 *. abs_float x) in
  let tau = t *. exp (-.x *. x -. 1.26551223 +.
    t *. (1.00002368 +. t *. (0.37409196 +. t *. (0.09678418 +. t *. (-.0.18628806 +.
    t *. (0.27886807 +. t *. (-.1.13520398 +. t *. (1.48851587 +. t *. (-.0.82215223 +. t *. 0.17087277))))))))) in
  if x >= 0.0 then 1.0 -. tau else tau -. 1.0

let standard_normal_cdf (x : float) : float = 
  0.5 *. (1.0 +. erf (x /. sqrt 2.0))

let truncated_normal_den (low : float) (high : float) : float =
  standard_normal_cdf high -. standard_normal_cdf low 

(* Suppose low <= x <= high *)
let truncated_normal_pdf (low : float) (high : float) (den : float) = 
  fun x -> standard_normal_pdf x /. den

let standard_laplace_pdf (x : float) : float = 
  let sigma = 1. in 
  exp (-. (abs_float x) /. sigma) /. (2. *. sigma)

let standard_laplace_cdf (x : float) : float = 
  let sigma = 1. in
  if x < 0. then 0.5 *. exp (x /. sigma)
  else 1. -. 0.5 *. exp (-. x /. sigma)

let truncated_laplace_den (low : float) (high : float) : float = 
  standard_laplace_cdf high -. standard_laplace_cdf low

(* Suppose low <= x <= high *)
let truncated_laplace_pdf (low : float) (high : float) (den : float) = 
  fun x -> standard_laplace_pdf x /. den

let nth_moment (n : int) (low : float) (high : float) pdf = 
  let f = fun x -> x ** (float_of_int n) *. (pdf x) in 
  let ret = num_itg f low high in 
  ret 

(* Suppose low <= high *)
let nth_moment_pos (n : int) (low : float) (high : float) pdf = 
  if high <= 0. then 0. 
  else let f = fun x -> x ** (float_of_int n) *. (pdf x) in 
  let ret = num_itg f (max 0. low) high in 
  ret

(* Suppose low <= high *)
let nth_moment_neg (n : int) (low : float) (high : float) pdf = 
  if low >= 0. then 0.
  else let f = fun x -> (-. x) ** (float_of_int n) *. (pdf x) in 
  let ret = num_itg f low (min 0. high) in 
  ret

let uniform_nth_moment (n : int) (low : float) (high : float) : float = 
  let pdf = uniform_pdf low high in 
  nth_moment n low high pdf

let uniform_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  let pdf = uniform_pdf low high in 
  nth_moment_pos n low high pdf

let uniform_nth_moment_neg (n : int) (low : float) (high : float) : float =
  let pdf = uniform_pdf low high in 
  nth_moment_neg n low high pdf

let normal_nth_moment (n : int) (low : float) (high : float) : float = 
  let den = truncated_normal_den low high in 
  let pdf = truncated_normal_pdf low high den in 
  nth_moment n low high pdf 

let normal_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  let den = truncated_normal_den low high in 
  let pdf = truncated_normal_pdf low high den in 
  nth_moment_pos n low high pdf

let normal_nth_moment_neg (n : int) (low : float) (high : float) : float =
  let den = truncated_normal_den low high in 
  let pdf = truncated_normal_pdf low high den in 
  nth_moment_neg n low high pdf

let laplace_nth_moment (n : int) (low : float) (high : float) : float = 
  let den = truncated_laplace_den low high in 
  let pdf = truncated_laplace_pdf low high den in 
  nth_moment n low high pdf

let laplace_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  let den = truncated_laplace_den low high in 
  let pdf = truncated_laplace_pdf low high den in 
  nth_moment_pos n low high pdf

let laplace_nth_moment_neg (n : int) (low : float) (high : float) : float =
  let den = truncated_laplace_den low high in 
  let pdf = truncated_laplace_pdf low high den in 
  nth_moment_neg n low high pdf

let uniform_expectation_of_name (n : int) (pos : int) (neg : int) (low : float) (high : float) : float = 
  if (pos > 0 && neg > 0) then 0.
  else if (pos = 0 && neg = 0) then uniform_nth_moment n low high 
  else if (pos = 0) then (-1. ** (float_of_int n)) *. (uniform_nth_moment_neg (n + neg) low high)
  else if (neg = 0) then uniform_nth_moment_pos (n + pos) low high 
  else failwith "Unexpected case"

(* A record of the already calculated expectations *)
type rcd = ((rv * int * float * float), float) Hashtbl.t

let print_rcd (rcd : rcd) = 
  Hashtbl.iter (fun (rv, n, low, high) ret -> 
    printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret) rcd

let uniform_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) (rcd : rcd) : (float * rcd) = 
  let (rv, n) = rv in 
  if Hashtbl.mem rcd (rv, n, low, high) then 
    (Hashtbl.find rcd (rv, n, low, high), rcd)
  else match rv with 
  | Rv _ -> let ret = uniform_nth_moment n low high in 
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Prv _ -> let ret = uniform_nth_moment_pos n low high in 
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Nrv _ -> let ret = uniform_nth_moment_neg n low high in 
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)

(* rv1 and rv2 should have the same name *)
let uniform_expectation_of_two_rvs ((rv1, n1) : (rv * int)) ((rv2, n2) : (rv * int)) (low : float) (high : float) (rcd : rcd) : (float * rcd) = 
  match (rv1, rv2) with
  | (Rv _, Rv _) -> uniform_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Rv _, Prv _) -> uniform_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Rv _, Nrv _) -> 
    let (ret', rcd) = (uniform_expectation_of_one_rv (rv2, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n1)) *. ret', rcd)
  | (Prv _, Rv _) -> uniform_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Prv _, Prv _) -> uniform_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Prv _, Nrv _) -> (0., rcd)
  | (Nrv _, Rv _) -> 
    let (ret', rcd) = (uniform_expectation_of_one_rv (rv1, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n2)) *. ret', rcd)
  | (Nrv _, Prv _) -> (0., rcd)
  | (Nrv _, Nrv _) -> uniform_expectation_of_one_rv (rv1, n1 + n2) low high rcd

let normal_expectation_of_one_rv (rv : rv * int) (low : float) (high : float)  (rcd : rcd) : (float * rcd) = 
  let (rv, n) = rv in 
  if Hashtbl.mem rcd (rv, n, low, high) then 
    (Hashtbl.find rcd (rv, n, low, high), rcd)
  else match rv with 
  | Rv _ -> let ret = normal_nth_moment n low high in 
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Prv _ -> let ret = normal_nth_moment_pos n low high in
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Nrv _ -> let ret = normal_nth_moment_neg n low high in
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)

let normal_expectation_of_two_rvs ((rv1, n1) : rv * int) ((rv2, n2) : rv * int) (low : float) (high : float) (rcd : rcd) : (float * rcd) =
  match (rv1, rv2) with
  | (Rv _, Rv _) -> normal_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Rv _, Prv _) -> normal_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Rv _, Nrv _) -> 
    let (ret', rcd) = (normal_expectation_of_one_rv (rv2, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n1)) *. ret', rcd)
  | (Prv _, Rv _) -> normal_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Prv _, Prv _) -> normal_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Prv _, Nrv _) -> (0., rcd)
  | (Nrv _, Rv _) -> 
    let (ret', rcd) = (normal_expectation_of_one_rv (rv1, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n2)) *. ret', rcd)
  | (Nrv _, Prv _) -> (0., rcd)
  | (Nrv _, Nrv _) -> normal_expectation_of_one_rv (rv1, n1 + n2) low high rcd

let laplace_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) (rcd : rcd) : (float * rcd) = 
  let (rv, n) = rv in 
  if Hashtbl.mem rcd (rv, n, low, high) then 
    (Hashtbl.find rcd (rv, n, low, high), rcd)
  else match rv with 
  | Rv _ -> let ret = laplace_nth_moment n low high in 
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Prv _ -> let ret = laplace_nth_moment_pos n low high in
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)
  | Nrv _ -> let ret = laplace_nth_moment_neg n low high in
    (* printf "%s, n=%d, low=%f, high=%f => %f\n" (string_of_rv rv) n low high ret; *)
    Hashtbl.add rcd (rv, n, low, high) ret; (ret, rcd)

let laplace_expectation_of_two_rvs ((rv1, n1) : rv * int) ((rv2, n2) : rv * int) (low : float) (high : float) (rcd : rcd) : (float * rcd) =
  match (rv1, rv2) with
  | (Rv _, Rv _) -> laplace_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Rv _, Prv _) -> laplace_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Rv _, Nrv _) -> 
    let (ret', rcd) = (laplace_expectation_of_one_rv (rv2, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n1)) *. ret', rcd)
  | (Prv _, Rv _) -> laplace_expectation_of_one_rv (rv1, n1 + n2) low high rcd
  | (Prv _, Prv _) -> laplace_expectation_of_one_rv (rv2, n1 + n2) low high rcd
  | (Prv _, Nrv _) -> (0., rcd)
  | (Nrv _, Rv _) -> 
    let (ret', rcd) = (laplace_expectation_of_one_rv (rv1, n1 + n2) low high rcd) in
    ((-1. ** (float_of_int n2)) *. ret', rcd)
  | (Nrv _, Prv _) -> (0., rcd)
  | (Nrv _, Nrv _) -> laplace_expectation_of_one_rv (rv1, n1 + n2) low high rcd

let match_first_name (name : string) (rvs : (rv * int) list) : ((rv * int) * ((rv * int) list)) option =
  match rvs with 
  | [] -> None 
  | (rv, n) :: rest -> if (rv_to_name_no_sign rv) = name then Some ((rv, n), rest) else None

(* Assume no three consecutive vars with same name i.e., zero term eliminated *)
let rec expectation_of_rvs (rvs : (rv * int) list) (vars : (string, distr) Hashtbl.t) (rcd : rcd) : (float * rcd) = 
  match rvs with 
  | [] -> (1., rcd) 
  | (rv, n) :: rest -> 
    let name = rv_to_name_no_sign rv in 
    let match_result = match_first_name name rest in
    (match match_result with
    | None -> let d = Hashtbl.find vars name in
      (match d with 
      | Uniform (low, high) -> 
        let (reth, rcd') = uniform_expectation_of_one_rv (rv, n) low high rcd in 
        let (rett, rcd'') = expectation_of_rvs rest vars rcd' in 
        (reth *. rett, rcd'')
      | Normal (low, high) -> 
        let (reth, rcd') = normal_expectation_of_one_rv (rv, n) low high rcd in
        let (rett, rcd'') = expectation_of_rvs rest vars rcd' in
        (reth *. rett, rcd'')
      | Exponential (low, high) -> 
        let (reth, rcd') = laplace_expectation_of_one_rv (rv, n) low high rcd in
        let (rett, rcd'') = expectation_of_rvs rest vars rcd' in
        (reth *. rett, rcd'')
      | _ -> failwith "expectation_of_rvs: Unsupported distribution type")
    | Some ((rv', n'), rest') -> let d = Hashtbl.find vars name in 
      (match d with 
      | Uniform (low, high) -> 
        let (reth, rcd') = uniform_expectation_of_two_rvs (rv, n) (rv', n') low high rcd in 
        let (rett, rcd'') = expectation_of_rvs rest' vars rcd' in 
        (reth *. rett, rcd'')
      | Normal (low, high) ->
        let (reth, rcd') = normal_expectation_of_two_rvs (rv, n) (rv', n') low high rcd in 
        let (rett, rcd'') = expectation_of_rvs rest' vars rcd' in 
        (reth *. rett, rcd'')
      | Exponential (low, high) -> 
        let (reth, rcd') = laplace_expectation_of_two_rvs (rv, n) (rv', n') low high rcd in 
        let (rett, rcd'') = expectation_of_rvs rest' vars rcd' in 
        (reth *. rett, rcd'')
      | _ -> failwith "expectation_of_rvs: Unsupported distribution type"))

let expectation_of_term (t : term) (vars : (string, distr) Hashtbl.t) (rcd : rcd) : (float * rcd) = 
  let (c, rvs) = t in 
  let (ret, rcd') = expectation_of_rvs rvs vars rcd in 
  (c *. ret, rcd')

let expectation_of_expanded_expr (f : expanded_expr) (vars : (string, distr) Hashtbl.t) (rcd : rcd) : (float * rcd) = 
  List.fold_left 
    (fun (acc_ret, acc_rcd) t -> let (ret, rcd') = expectation_of_term t vars acc_rcd in (acc_ret +. ret, rcd'))
    (0., rcd) f

let expectation_of_term_verbose (t : term) (vars : (string, distr) Hashtbl.t) (rcd : rcd) : (float * rcd) = 
  let (c, rvs) = t in 
  printf "Computing expectation of term: %s\n" (string_of_term t);
  let (ret, rcd') = expectation_of_rvs rvs vars rcd in 
  printf "%s : %e\n\n" (string_of_term t) (c *. ret);
  (c *. ret, rcd')

let expectation_of_expanded_expr_verbose (f : expanded_expr) (vars : (string, distr) Hashtbl.t) (rcd : rcd) : (float * rcd) = 
  List.fold_left 
    (fun (acc_ret, acc_rcd) t -> let (ret, rcd') = expectation_of_term_verbose t vars acc_rcd in (acc_ret +. ret, rcd'))
    (0., rcd) f

(* let expectation_of_term_verbose (t : term) (vars : (string, distr) Hashtbl.t) : float = 
  let (c, rvs) = t in 
  let ret = c *. (expectation_of_rvs rvs vars) in
  Printf.printf "%s : %e\n" (string_of_term t) ret;
  ret

let expectation_of_expanded_expr_verbose (f : expanded_expr) (vars : (string, distr) Hashtbl.t) : float =
  List.fold_left (fun acc t -> acc +. (expectation_of_term_verbose t vars)) 0. f *)

