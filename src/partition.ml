open Expr
open Input_parser
open Ops 
open Expectation
open Printf

let concat_map f l = 
  let rec aux f acc = function
  | [] -> List.rev acc
  | x :: l -> 
      let xs = f x in 
      aux f (List.rev_append xs acc) l
  in aux f [] l

let rec cartesian_product_aux acc = function
  | [] -> acc
  | xs :: xss ->
    let acc = concat_map (fun x -> map_tailrec (fun ys -> x :: ys) acc) xs in
    cartesian_product_aux acc xss

let cartesian_product lst = 
  (* List.iter (fun l -> printf "length of sublist: %d\n" (List.length l)) lst; *)
  cartesian_product_aux [[]] lst

let rec cartesian_product_float_aux acc = function 
  | [] -> acc 
  | xs :: xss -> 
    let acc = concat_map (fun x -> map_tailrec (fun ys -> x *. ys) acc) xs in 
    cartesian_product_float_aux acc xss

let cartesian_product_float lst = 
  cartesian_product_float_aux [1.] lst

let split_var_aux_with_weight (distribution : Expr.distr) num_interval : (Expr.distr list * float list) = 
  match distribution with 
  | Uniform (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in 
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        aux (i + 1) ((Uniform (new_low, new_hi)) :: acc_d) ((1. /. (float_of_int num_interval)) :: acc_w)
      in aux 0 [] []
  | Normal (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in
    let total_weight = standard_normal_cdf hi -. standard_normal_cdf low in
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        let weight = standard_normal_cdf new_hi -. standard_normal_cdf new_low in
        aux (i + 1) ((Normal (new_low, new_hi)) :: acc_d) ((weight /. total_weight) :: acc_w)
      in aux 0 [] []
  | Exponential (low, hi) ->
    let step = (hi -. low) /. float_of_int num_interval in
    let total_weight = standard_laplace_cdf hi -. standard_laplace_cdf low in
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        let weight = standard_laplace_cdf new_hi -. standard_laplace_cdf new_low in
        aux (i + 1) ((Exponential (new_low, new_hi)) :: acc_d) ((weight /. total_weight) :: acc_w)
      in aux 0 [] []
  | _ -> failwith "split_var_aux_with_weight: Unsupported distribution type"
  (* | Wide (low, hi) -> 
    let step = (hi -. low) /. float_of_int num_interval in
    let total_weight = wide_normal_cdf hi -. wide_normal_cdf low in
    let rec aux i acc_d acc_w = 
      if i >= num_interval then (acc_d, acc_w)
      else 
        let new_low = low +. (step *. float_of_int i) in 
        let new_hi = low +. (step *. float_of_int (i + 1)) in 
        let weight = wide_normal_cdf new_hi -. wide_normal_cdf new_low in
        aux (i + 1) ((Wide (new_low, new_hi)) :: acc_d) ((weight /. total_weight) :: acc_w)
      in aux 0 [] [] *)

let split_var_with_weight (name, distribution) num_interval : (string * Expr.distr) list * float list = 
  let (split_distribution, weights) = split_var_aux_with_weight distribution num_interval in
  let split_vars = List.map (fun d -> (name, d)) split_distribution in
  (split_vars, weights)

let split_vars_with_weight vars num_interval = 
  let vars_list = Hashtbl.fold (fun key value acc -> (key, value) :: acc) vars [] in
  let split_vars_list = List.map (fun (name, distribution) -> split_var_with_weight (name, distribution) num_interval) vars_list in
  let cartprod = (cartesian_product (List.map fst split_vars_list)) in 
  let combinations = map_tailrec hashtbl_of_list cartprod in
  let weights = cartesian_product_float (List.map snd split_vars_list) in
  combine_tailrec combinations weights
  (* List.combine combinations weights  *)