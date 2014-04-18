
type t =
  | False
  | True
  | Not of t
  | Or of t * t
  | And of t * t
  | Var of string

let rec to_string = function
  | False -> "false"
  | True -> "true"
  | Not t -> Printf.sprintf "-%s" (to_string t)
  | And (t, t') -> Printf.sprintf "(%s * %s)" (to_string t) (to_string t')
  | Or (t, t') -> Printf.sprintf "(%s + %s)" (to_string t) (to_string t')
  | Var v -> v

let (+) t t' = Or (t, t')
let ( * ) t t' = And (t, t')
let (~-) t = Not t
let (==>) t t' = ~-t + t'
let (<==) t t' = t + ~-t'
let (<=>) t t' = (t ==> t') * (t' ==> t)

(* Map with String as a key. Used only inside the module. *)
module SM = Map.Make(String)
(* Map with Int as a key. Used only inside the module. *)
module IM = Map.Make(struct type t = int let compare = Pervasives.compare end)

let rec simplify = function
  | Not t ->
    begin
      match simplify t with
      | True -> False
      | False -> True
      | Not x -> x
      | x -> Not x
    end
  | Or (t, t') ->
    begin
      match simplify t, simplify t' with
      | True, _ -> True
      | _, True -> True
      | False, False -> False
      | x, x' -> Or (x, x')
    end
  | And (t, t') ->
    begin
      match simplify t, simplify t' with
      | False, _ -> False
      | _, False -> False
      | True, True -> True
      | x, x' -> And (x, x')
    end
  | t -> t

let rec to_cnf t =
  (* explicit formula simplification *)
  let t = simplify t in
  match t with
  | And (p, q) -> (to_cnf p) @ (to_cnf q)
  | Or (p, q) ->
    let cnf, cnf' = to_cnf p, to_cnf q in
    let module L = List in
    (* cartesian product of left and right terms *)
    L.fold_left
      (fun acc x ->
        L.fold_left (fun acc x' ->
          (x @ x') :: acc
        ) acc cnf'
      ) [] cnf
  | Not (Not x) -> to_cnf x
  | Not (And (p, q)) -> to_cnf (~-p + ~-q)
  | Not (Or (p, q)) -> (to_cnf ~-p) @ (to_cnf ~-q)
  | x -> [[x]]

(* add constraints provided in the CNF form to PicoSat *)
let cnf_to_psat cnf smap =
  let module L = List in
  let module P = Picosat in
  let psat = ref (P.init ()) in
  L.iter (fun lst ->
    L.iter (function
      | Var v -> ignore (P.add !psat (SM.find v smap))
      | Not (Var v) ->
        ignore (P.add !psat Pervasives.(~-1 * (SM.find v smap)))
      | _ -> failwith "wrong logical expression"
    ) lst;
    ignore (P.add !psat 0)
  ) cnf;
  psat

(* get a model from the solver.
   NOTE: [solve] function must be called before. *)
let get_solution psat =
  let values = ref [] in
  let max_idx = Picosat.variables !psat in
  for i = 1 to max_idx do
    values := (Picosat.deref !psat i) :: !values
  done;
  if List.mem 0 !values then None
  else Some (List.rev !values)

let lst_to_cnf lst =
  List.fold_left (fun acc x -> (to_cnf x) @ acc) [] lst

(* associate variables with successive integer terms and return two associative
   lists *)
let index_variables lst =
  let module Perv = Pervasives in
  let rec index ((imap, smap, counter) as acc) x =
    match x with
      | Var v ->
        if SM.mem v smap then acc
        else (IM.add counter v imap, SM.add v counter smap, Perv.(counter + 1))
      | Not t -> index acc t
      | Or (t, t')
      | And (t, t') -> index (index acc t) t'
      | _ -> acc in
  let imap, smap, _ = List.fold_left index (IM.empty, SM.empty, 1) lst in
  imap, smap

let find_models t_lst single_model =
  let imap, smap = index_variables t_lst in
  let psat = cnf_to_psat (lst_to_cnf t_lst) smap in
  let result = ref [] in
  let loop = ref true in
  let module Perv = Pervasives in
  while !loop do
    if Perv.(Picosat.sat !psat Perv.(~-1) = Picosat.Satisfiable) then
      match get_solution psat with
      | Some x ->
        let assignment = ref SM.empty in
        let counter = ref 1 in
        List.iter (fun v ->
          ignore (Picosat.add !psat Perv.(~-1 * !counter * v));
          (* add a variable value to the assignment *)
          assignment :=
            SM.add
              (IM.find !counter imap)
              (if v > 0 then true else false)
              !assignment;
          counter := Perv.(!counter + 1)
        ) x;
        ignore (Picosat.add !psat 0);
        result :=  !assignment :: !result;
        if single_model then loop := false
      | None -> loop := false
    else
      loop := false
  done;
  !result

let all_solutions t_lst =
  match find_models t_lst false with
  | [] -> None
  | lst -> Some (List.map SM.bindings lst)

let solve t_lst =
  match find_models t_lst true with
  | [] -> None
  | hd :: _ -> Some (SM.bindings hd)
