
(* source: http://fmv.jku.at/biere/talks/Biere-TPTPA11.pdf *)

let _ =
  let open Picosat in
  let psat = init () in
  let _ = add psat ~-2 in
  let _ = add psat 0 in
  let _ = add psat ~-1 in
  let _ = add psat ~-3 in
  let _ = add psat 0 in
  let _ = add psat 1 in
  let _ = add psat 2 in
  let _ = add psat 0 in
  let _ = add psat 2 in
  let _ = add psat 3 in
  let _ = add psat 0 in
  match sat psat ~-1 with
  | Unknown -> print_endline "UNKNOWN"
  | Satisfiable -> print_endline "SATISFIABLE"
  | Unsatisfiable -> print_endline "UNSATISFIABLE"
