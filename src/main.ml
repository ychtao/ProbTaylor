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

let get_tri_flag () = 
  Array.exists (fun arg -> arg = "--tri") Sys.argv

let get_output_filename () =
  let default_out = Sys.argv.(1) ^ ".out" in 
  let out = ref default_out in
  let argv = Array.to_list Sys.argv in
  let rec parse = function
    | "-o" :: v :: _ -> (out := v; ())
    | _ :: tl -> parse tl
    | [] -> ()
  in parse argv; !out


let _ =
  let start_time = Unix.gettimeofday () in
  let filename = Sys.argv.(1) in
  let outname = get_output_filename () in

  Printf.printf "Analyzing program: %s...\n" filename;
  flush_all ();

  let ensure_parent_dir path =
    let dir = Filename.dirname path in
    let rec aux d =
      if d = "" || d = "." then ()
      else if Sys.file_exists d then
        if Sys.is_directory d then () else failwith (d ^ " exists but is not a directory")
      else (aux (Filename.dirname d); Unix.mkdir d 0o755)
    in aux dir
  in
  ensure_parent_dir outname;
  let oc = open_out outname in
  try
    let eps = get_eps () in
    let dlt = get_dlt () in
    let cfd = get_cfd () in
    let order = get_order () in
    let num_intervals = get_num_intervals () in
    if get_nm_flag () then (
      let u = naive_markov filename eps cfd order in
      Printf.fprintf oc "%s\n" filename;
      Printf.fprintf oc "Naive Markov, order = %d\n" order;
      Printf.fprintf oc "1st-order error threshold = %e\n" u
    ) else if get_cmb_flag () then (
      let u = central_moment_based filename eps cfd order num_intervals in
      Printf.fprintf oc "%s\n" filename;
      Printf.fprintf oc "Central moment based, order = %d, num = %d\n" order num_intervals;
      Printf.fprintf oc "1st-order error threshold = %e\n" u
    ) else if get_div_flag () then (
      let u = central_moment_based_div filename eps cfd order num_intervals in
      Printf.fprintf oc "%s\n" filename;
      Printf.fprintf oc "Central moment based (fractional expression), order = %d, num = %d\n" order num_intervals;
      Printf.fprintf oc "1st-order error threshold = %e\n" u
    ) else (
      let (best_u, best_order) = naive_markov_opt filename eps cfd order in
      Printf.fprintf oc "%s\n" filename;
      Printf.fprintf oc "Naive Markov Opt, max order = %d\n" order;
      Printf.fprintf oc "1st-order error threshold = %e\n" best_u;
      Printf.fprintf oc "Optimal analysis order = %d\n" best_order
    );
    flush oc;
    let end_error1_time = Unix.gettimeofday () in
    Printf.fprintf oc "First-order analysis time: %.2fs\n" (end_error1_time -. start_time);

    if (get_er1_flag ()) 
      then (Printf.fprintf oc "Note: Second-order error analysis skipped as per --er1 flag.\n")
    else (
      let err2_bound = (if (get_tri_flag()) then (bound_error2_tri filename eps dlt) 
        else (bound_error2_gelpia filename eps dlt)) in 
      Printf.fprintf oc "Second-order error threshold = %e\n" err2_bound;
      let end_error2_time = Unix.gettimeofday () in 
      Printf.fprintf oc "Second-order analysis time: %2fs\n " (end_error2_time -. end_error1_time);
      flush oc
    );
    close_out oc;

    Printf.printf "Analysis done!\n"
  with e ->
    close_out_noerr oc;
    raise e

(* let _ = 
  let start_time = Unix.gettimeofday () in 
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
  let end_error1_time = Unix.gettimeofday () in 
  printf "First-order analysis time: %.2fs\n" (end_error1_time -. start_time);
  if not (get_er1_flag ()) then 
    ((if (get_tri_flag ()) then bound_error2_tri filename eps dlt
    else let _ = bound_error2_gelpia filename eps dlt in ());
    let end_error2_time = Unix.gettimeofday () in 
    printf "Second-order analysis time: %.2fs\n" (end_error2_time -. end_error1_time);
    flush_all ()) *)
