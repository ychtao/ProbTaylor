open Printf
open Poly
open Div
open Error2

let get_eps () = 
  let default_eps = 2. ** (-24.) in 
  let eps = ref default_eps in 
  let argv = Array.to_list Sys.argv in 
  let rec parse = function
  | "--eps" :: v :: _ -> (try eps := float_of_string v with _ -> ()); ()
  | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !eps

let get_dlt () = 
  let default_dlt = 2. ** (-126.) in 
  let dlt = ref default_dlt in 
  let argv = Array.to_list Sys.argv in 
  let rec parse = function
  | "--dlt" :: v :: _ -> (try dlt := float_of_string v with _ -> ()); ()
  | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !dlt

let get_cfd () = 
  let default_cfd = 0.99 in 
  let cfd = ref default_cfd in 
  let argv = Array.to_list Sys.argv in 
  let rec parse = function
  | "--cfd" :: v :: _ -> (try cfd := float_of_string v with _ -> ()); ()
  | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !cfd

let get_order () =
  let default_order = 2 in
  let order = ref default_order in
  let argv = Array.to_list Sys.argv in
  let rec parse = function
    | "--order" :: v :: _ -> (try order := int_of_string v with _ -> ()); ()
    | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !order

let get_num_intervals () =
  let default_num = 32 in
  let num_intervals = ref default_num in
  let argv = Array.to_list Sys.argv in
  let rec parse = function
    | "--num" :: v :: _ -> (try num_intervals := int_of_string v with _ -> ()); ()
    | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !num_intervals

let get_nm_flag () = 
  Array.exists (fun arg -> arg = "--nm") Sys.argv

let get_cmb_flag () = 
  Array.exists (fun arg -> arg = "--cmb") Sys.argv

let get_nm_opt_flag () =
  Array.exists (fun arg -> arg = "--nmopt") Sys.argv

let get_div_flag () = 
  Array.exists (fun arg -> arg = "--div") Sys.argv 

let get_er1_flag () = 
  Array.exists (fun arg -> arg = "--er1") Sys.argv

let _ = 
  let filename = Sys.argv.(1) in
  let eps = get_eps () in 
  let dlt = get_dlt () in 
  let cfd = get_cfd () in 
  let order = get_order () in 
  let num_intervals = get_num_intervals () in 
  if get_nm_flag () then (
    let u = naive_markov filename eps cfd order in 
    printf "%s\n" filename;
    printf "Naive Markov, order = %d\n" order;
    printf "1st-order error threshold = %e\n" u
  ) else if get_cmb_flag () then (
    let u = central_moment_based filename eps cfd order num_intervals in 
    printf "%s\n" filename;
    printf "Central moment based, order = %d, num = %d\n" order num_intervals;
    printf "1st-order error threshold = %e\n" u
  ) else if get_div_flag () then (
    let u = central_moment_based_div filename eps cfd order num_intervals in 
    printf "%s\n" filename;
    printf "Central moment based (fractional expression), order = %d, num = %d\n" order num_intervals;
    printf "1st-order error threshold = %e\n" u
  ) else (
    let (best_u, best_order) = naive_markov_opt filename eps cfd order in 
    printf "%s\n" filename;
    printf "Naive Markov Opt, max order = %d\n" order;
    printf "1st-order error threshold = %e\n" best_u;
    printf "Optimal analysis order = %d\n" best_order
  );
  flush_all ();
  if not (get_er1_flag ()) then bound_error2 filename eps dlt else 0
