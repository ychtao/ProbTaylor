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
  if high <= 0. then (uniform_nth_moment n (-. high) (-. low))
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
  | Rv _ -> uniform_nth_moment n low high
  | Prv _ -> uniform_nth_moment_pos n low high
  | Nrv _ -> uniform_nth_moment_neg n low high

(* rv1 and rv2 should have the same name *)
let uniform_expectation_of_two_rvs ((rv1, n1) : (rv * int)) ((rv2, n2) : (rv * int)) (low : float) (high : float) : float = 
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

(* Can do when mean is not zero *)
let standard_normal_pdf (x : float) : float = 
  1. /. (sqrt (2. *. Float.pi)) *. (exp (-0.5 *. x *. x))

let erf x =
  let t = 1.0 /. (1.0 +. 0.5 *. abs_float x) in
  let tau = t *. exp (-.x *. x -. 1.26551223 +.
    t *. (1.00002368 +. t *. (0.37409196 +. t *. (0.09678418 +. t *. (-.0.18628806 +.
    t *. (0.27886807 +. t *. (-.1.13520398 +. t *. (1.48851587 +. t *. (-.0.82215223 +. t *. 0.17087277))))))))) in
  if x >= 0.0 then 1.0 -. tau else tau -. 1.0

let standard_normal_cdf (x : float) : float = 
  0.5 *. (1.0 +. erf (x /. sqrt 2.0))

let rec normal_nth_moment (n : int) (low : float) (high : float) : float = 
  if n = 0 then 1.
  else if n = 1 then (standard_normal_pdf low -. standard_normal_pdf high) /. (standard_normal_cdf high -. standard_normal_cdf low)
  else let num = low ** (float_of_int (n - 1)) *. standard_normal_pdf low -. high ** (float_of_int (n - 1)) *. standard_normal_pdf high in
       let den = standard_normal_cdf high -. standard_normal_cdf low in
       num /. den +. (float_of_int n -. 1.) *. normal_nth_moment (n - 2) low high

let rec normal_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  if low >= 0. then normal_nth_moment n low high
  else if high <= 0. then 0.
  else if n = 0 then (standard_normal_cdf high -. standard_normal_cdf 0.) /. (standard_normal_cdf high -. standard_normal_cdf low)
  else if n = 1 then (standard_normal_pdf 0. -. standard_normal_pdf high) /. (standard_normal_cdf high -. standard_normal_cdf low)
  else let num = -. (high ** (float_of_int (n - 1))) *. standard_normal_pdf high in 
       let den = standard_normal_cdf high -. standard_normal_cdf low in
        num /. den +. (float_of_int (n - 1)) *. normal_nth_moment_pos (n - 2) low high

let rec normal_nth_moment_neg (n : int) (low : float) (high : float) : float = 
  if high <= 0. then -. (normal_nth_moment n low high)
  else if low >= 0. then 0.
  else if n = 0 then (standard_normal_cdf 0. -. standard_normal_cdf low) /. (standard_normal_cdf high -. standard_normal_cdf low)
  else if n = 1 then (standard_normal_pdf 0. -. standard_normal_pdf low) /. (standard_normal_cdf high -. standard_normal_cdf low)
  else let num = (-1.) ** (float_of_int n) *. low ** (float_of_int (n - 1)) *. standard_normal_pdf low in
       let den = standard_normal_cdf high -. standard_normal_cdf low in
       num /. den +. (float_of_int (n - 1)) *. normal_nth_moment_neg (n - 2) low high

let normal_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) : float = 
  let (rv, n) = rv in 
  match rv with 
  | Rv x -> normal_nth_moment n low high
  | Prv x -> normal_nth_moment_pos n low high
  | Nrv x -> normal_nth_moment_neg n low high

let normal_expectation_of_two_rvs (rv1 : rv * int) (rv2 : rv * int) (low : float) (high : float) : float =
  let (rv1, n1) = rv1 in
  let (rv2, n2) = rv2 in
  match (rv1, rv2) with
  | (Rv _, Rv _) -> normal_nth_moment (n1 + n2) low high
  | (Rv _, Prv _) -> normal_nth_moment_pos (n1 + n2) low high
  | (Rv _, Nrv _) -> (-1. ** (float_of_int n1)) *. (normal_nth_moment_neg (n1 + n2) low high)
  | (Prv _, Rv _) -> normal_nth_moment_pos (n1 + n2) low high
  | (Prv _, Prv _) -> normal_nth_moment_pos (n1 + n2) low high
  | (Prv _, Nrv _) -> 0.
  | (Nrv _, Rv _) -> (-1. ** (float_of_int n2)) *. (normal_nth_moment_neg (n1 + n2) low high)
  | (Nrv _, Prv _) -> 0.
  | (Nrv _, Nrv _) -> normal_nth_moment_neg (n1 + n2) low high

(* Begins wide normal distribution *)

let wide_normal_pdf (x : float) : float = 
  let sigma = 10. in 
  1. /. (sqrt (2. *. Float.pi *. sigma *. sigma)) *. (exp (-. x *. x /. (2. *. sigma *. sigma)))

let wide_normal_cdf (x : float) : float = 
  let sigma = 10. in 
  standard_normal_cdf (x /. sigma)

let rec wide_normal_nth_moment (n : int) (low : float) (high : float) : float = 
  let sigma = 10. in 
  if n = 0 then 1.
  else if n = 1 then sigma *. sigma *. (wide_normal_pdf low -. wide_normal_pdf high) /. (wide_normal_cdf high -. wide_normal_cdf low)
  else let num = sigma *. sigma *. (low ** (float_of_int (n - 1)) *. wide_normal_pdf low -. high ** (float_of_int (n - 1)) *. wide_normal_pdf high) in
       let den = wide_normal_cdf high -. wide_normal_cdf low in
       (* printf "%d %e %e \n" n num den;
       printf "num / den: %e\n" (num /. den);
       printf "add: %e\n" (sigma *. sigma *. (float_of_int n -. 1.) *. wide_normal_nth_moment (n - 2) low high); *)
       num /. den +. sigma *. sigma *. (float_of_int n -. 1.) *. wide_normal_nth_moment (n - 2) low high

let rec wide_normal_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  let sigma = 10. in 
  if low >= 0. then wide_normal_nth_moment n low high 
  else if high <= 0. then 0. 
  else if n = 0 then (wide_normal_cdf high -. wide_normal_cdf 0.) /. (wide_normal_cdf high -. wide_normal_cdf low)
  else if n = 1 then sigma *. sigma *. (wide_normal_pdf 0. -. wide_normal_pdf high) /. (wide_normal_cdf high -. wide_normal_cdf low)
  else let num = sigma *. sigma *. (high ** (float_of_int (n - 1))) *. wide_normal_pdf high in 
       let den = wide_normal_cdf high -. wide_normal_cdf low in
       num /. den +. (float_of_int (n - 1)) *. sigma *. sigma *. wide_normal_nth_moment_pos (n - 2) low high 

let rec wide_normal_nth_moment_neg (n : int) (low : float) (high : float) : float = 
  let sigma = 10. in 
  if high <= 0. then -. (wide_normal_nth_moment n low high)
  else if low >= 0. then 0. 
  else if n = 0 then (wide_normal_cdf 0. -. wide_normal_cdf low) /. (wide_normal_cdf high -. wide_normal_cdf low)
  else if n = 1 then sigma *. sigma *. (wide_normal_pdf 0. -. wide_normal_pdf low) /. (wide_normal_cdf high -. wide_normal_cdf low)
  else let num = ((-1.) ** (float_of_int n)) *. sigma *. sigma *. (low ** (float_of_int (n - 1))) *. wide_normal_pdf low in 
       let den = wide_normal_cdf high -. wide_normal_cdf low in 
       num /. den +. sigma *. sigma *. (float_of_int (n - 1)) *. wide_normal_nth_moment_neg (n - 2) low high

let wide_normal_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) : float = 
  let (rv, n) = rv in 
  match rv with 
  | Rv x -> wide_normal_nth_moment n low high
  | Prv x -> wide_normal_nth_moment_pos n low high
  | Nrv x -> wide_normal_nth_moment_neg n low high

let wide_normal_expectation_of_two_rvs (rv1 : rv * int) (rv2 : rv * int) (low : float) (high : float) : float =
  let (rv1, n1) = rv1 in
  let (rv2, n2) = rv2 in
  match (rv1, rv2) with
  | (Rv _, Rv _) -> wide_normal_nth_moment (n1 + n2) low high
  | (Rv _, Prv _) -> wide_normal_nth_moment_pos (n1 + n2) low high
  | (Rv _, Nrv _) -> (-1. ** (float_of_int n1)) *. (wide_normal_nth_moment_neg (n1 + n2) low high)
  | (Prv _, Rv _) -> wide_normal_nth_moment_pos (n1 + n2) low high
  | (Prv _, Prv _) -> wide_normal_nth_moment_pos (n1 + n2) low high
  | (Prv _, Nrv _) -> 0.
  | (Nrv _, Rv _) -> (-1. ** (float_of_int n2)) *. (wide_normal_nth_moment_neg (n1 + n2) low high)
  | (Nrv _, Prv _) -> 0.
  | (Nrv _, Nrv _) -> wide_normal_nth_moment_neg (n1 + n2) low high

(* Ends wide normal distribution *)


let standard_laplace_pdf (x : float) : float = 
  let sigma = 1. in 
  exp (-. (abs_float x) /. sigma) /. (2. *. sigma)

let standard_laplace_cdf (x : float) : float = 
  let sigma = 1. in
  if x < 0. then 0.5 *. exp (x /. sigma)
  else 1. -. 0.5 *. exp (-. x /. sigma)

let rec ick_integral (c : float) (k : int) : float = 
  if k = 0 then 1. -. exp (-. c)
  else (float_of_int k) *. ick_integral c (k - 1) -. c ** (float_of_int k) *. exp (-. c) 

let laplace_nth_moment (n : int) (low : float) (high : float) : float =
  (* print_endline ("laplace_nth_moment" ^ (string_of_int n) ^ (string_of_float low) ^ (string_of_float high)); *)
  let sigma = 1. in 
  let den = standard_laplace_cdf high -. standard_laplace_cdf low in
  (* let den_ = standard_laplace_cdf high -. standard_laplace_cdf low in *)
  (* let den = if den_ = 0. then (Float.succ 0.) else den_ in *)
  if high <= 0. then 
    let i1 = 0.5 *. (-. sigma) ** (float_of_int n) *. (ick_integral (-. low /. sigma) n) in 
    let i2 = 0.5 *. (-. sigma) ** (float_of_int n) *. (ick_integral (-. high /. sigma) n) in
    (i1 -. i2) /. den 
  else if low >= 0. then 
    let i1 = 0.5 *. sigma ** (float_of_int n) *. (ick_integral (high /. sigma) n) in  
    let i2 = 0.5 *. sigma ** (float_of_int n) *. (ick_integral (low /. sigma) n) in
    (i1 -. i2) /. den
  else 
    let i1 = 0.5 *. (-. sigma) ** (float_of_int n) *. (ick_integral (-. low /. sigma) n) in
    let i2 = 0.5 *. sigma ** (float_of_int n) *. (ick_integral (high /. sigma) n) in
    (i1 +. i2) /. den

let laplace_nth_moment_pos (n : int) (low : float) (high : float) : float = 
  (* print_endline ("laplace_nth_moment_pos" ^ (string_of_int n) ^ (string_of_float low) ^ (string_of_float high)); *)
  let sigma = 1. in 
  let den = standard_laplace_cdf high -. standard_laplace_cdf low in
  if low >= 0. then laplace_nth_moment n low high 
  else if high <= 0. then 0.
  else let i1 = 0.5 *. sigma ** (float_of_int n) *. (ick_integral (high /. sigma) n) in
    i1 /. den 

let laplace_nth_moment_neg (n : int) (low : float) (high : float) : float = 
  (* print_endline ("laplace_nth_moment_neg" ^ (string_of_int n) ^ (string_of_float low) ^ (string_of_float high)); *)
  let sigma = 1. in 
  let den = standard_laplace_cdf high -. standard_laplace_cdf low in
  if high <= 0. then (-. 1.) ** (float_of_int n) *. (laplace_nth_moment n low high)
  else if low >= 0. then 0.
  else let i1 = 0.5 *. sigma ** (float_of_int n) *. (ick_integral (-. low /. sigma) n) in
    i1 /. den

let laplace_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) : float = 
  let (rv, n) = rv in 
  match rv with 
  | Rv x -> laplace_nth_moment n low high
  | Prv x -> laplace_nth_moment_pos n low high
  | Nrv x -> laplace_nth_moment_neg n low high

(* let laplace_expectation_of_one_rv (rv : rv * int) (low : float) (high : float) : float = 
  let (rv, n) = rv in 
  let ret = match rv with 
  | Rv x -> laplace_nth_moment n low high
  | Prv x -> laplace_nth_moment_pos n low high
  | Nrv x -> laplace_nth_moment_neg n low high in 
  print_endline (string_of_float ret); ret *)

let laplace_expectation_of_two_rvs (rv1 : rv * int) (rv2 : rv * int) (low : float) (high : float) =
  let (rv1, n1) = rv1 in
  let (rv2, n2) = rv2 in
  match (rv1, rv2) with
  | (Rv _, Rv _) -> laplace_nth_moment (n1 + n2) low high
  | (Rv _, Prv _) -> laplace_nth_moment_pos (n1 + n2) low high
  | (Rv _, Nrv _) -> (-1. ** (float_of_int n1)) *. (laplace_nth_moment_neg (n1 + n2) low high)
  | (Prv _, Rv _) -> laplace_nth_moment_pos (n1 + n2) low high
  | (Prv _, Prv _) -> laplace_nth_moment_pos (n1 + n2) low high
  | (Prv _, Nrv _) -> 0.
  | (Nrv _, Rv _) -> (-1. ** (float_of_int n2)) *. (laplace_nth_moment_neg (n1 + n2) low high)
  | (Nrv _, Prv _) -> 0.
  | (Nrv _, Nrv _) -> laplace_nth_moment_neg (n1 + n2) low high

let match_first_name (name : string) (rvs : (rv * int) list) : ((rv * int) * ((rv * int) list)) option =
  match rvs with 
  | [] -> None 
  | (rv, n) :: rest -> if (rv_to_name_no_sign rv) = name then Some ((rv, n), rest) else None

(* Assume no three consecutive vars with same name i.e., zero term eliminated *)
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
      | Normal (low, high) -> (normal_expectation_of_one_rv (rv, n) low high) *. (expectation_of_rvs rest vars)
      | Exponential (low, high) -> (laplace_expectation_of_one_rv (rv, n) low high) *. (expectation_of_rvs rest vars)
      | Wide (low, high) -> (wide_normal_expectation_of_one_rv (rv, n) low high) *. (expectation_of_rvs rest vars))
    | Some ((rv', n'), rest') -> let d = Hashtbl.find vars name in 
      (match d with 
      | Uniform (low, high) -> (uniform_expectation_of_two_rvs (rv, n) (rv', n') low high) *. (expectation_of_rvs rest' vars)
      | Normal (low, high) -> (normal_expectation_of_two_rvs (rv, n) (rv', n') low high) *. (expectation_of_rvs rest' vars)
      | Exponential (low, high) -> (laplace_expectation_of_two_rvs (rv, n) (rv', n') low high) *. (expectation_of_rvs rest' vars)
      | Wide (low, high) -> wide_normal_expectation_of_two_rvs (rv, n) (rv', n') low high *. (expectation_of_rvs rest' vars)))

let expectation_of_term (t : term) (vars : (string, distr) Hashtbl.t) : float = 
  let (c, rvs) = t in 
  let ret = c *. (expectation_of_rvs rvs vars) in
  (* Printf.printf "expectation of term %s = %f\n" (string_of_term t) ret; *)
  ret

let expectation_of_expanded_expr (f : expanded_expr) (vars : (string, distr) Hashtbl.t) : float = 
  List.fold_left (fun acc t -> acc +. (expectation_of_term t vars)) 0. f

let expectation_of_term_verbose (t : term) (vars : (string, distr) Hashtbl.t) : float = 
  let (c, rvs) = t in 
  let ret = c *. (expectation_of_rvs rvs vars) in
  Printf.printf "%s : %e\n" (string_of_term t) ret;
  ret

let expectation_of_expanded_expr_verbose (f : expanded_expr) (vars : (string, distr) Hashtbl.t) : float =
  List.fold_left (fun acc t -> acc +. (expectation_of_term_verbose t vars)) 0. f


