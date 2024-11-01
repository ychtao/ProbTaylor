open Tilde

let _ = 
  let in_file = "input.txt" in 
  let in_channel = open_in in_file in 
  let out_file = "tilde.txt" in 
  let out_channel = open_out out_file in 
  let lexbuf = Lexing.from_channel in_channel in 
  let f = Parser.main Lexer.token lexbuf in 
  let (tf, k) = (Tilde.tilde f) in 
  Printf.fprintf out_channel "%s\n" (string_of_expr tf);
  Printf.fprintf out_channel "%s\n" (string_of_int k);
  close_in in_channel;
  close_out out_channel
