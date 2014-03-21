
let _ =
  let formula = Logic.((Var "p") * (~-(Var "m")) + (Var "n")) in
  let result = Logic.all_solutions [formula] in
  match result with
  | None -> print_endline "Solution does not exist"
  | Some lst ->
    List.iter
      (fun x ->
        List.iter (fun (var, value) ->
          Printf.printf "%s <- %s\n" var (if value then "true" else "false")
        ) x;
        print_newline ()
      ) lst
