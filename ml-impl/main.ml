open Input_parser

let _ = 
  let filename = "Example.txt" in 
  let (vardecs, f) = process_input filename in 
  printf string_of_expr f