
type t = Unknown
       | Satisfiable
       | Unsatisfiable

open Ctypes

type picosat = unit ptr
let picosat : picosat typ = ptr void

open Foreign

let version =
  foreign "picosat_version" (void @-> returning string)

let config =
  foreign "picosat_config" (void @-> returning string)

let copyright =
  foreign "picosat_copyright" (void @-> returning string)

let init =
  foreign "picosat_init" (void @-> returning picosat)

let reset =
  foreign "picosat_reset" (picosat @-> returning void)

let measure_all_calls =
  foreign "picosat_measure_all_calls" (picosat @-> returning void)

let set_prefix =
  foreign "picosat_set_prefix" (picosat @-> string @-> returning void)

let set_verbosity =
  foreign "picosat_set_verbosity" (picosat @-> int @-> returning void)

let set_global_default_phase =
  foreign "picosat_set_global_default_phase"
    (picosat @-> int @-> returning void)

let set_default_phase_lit =
  foreign "picosat_set_default_phase_lit"
    (picosat @-> int @-> int @-> returning void)

let reset_phases =
  foreign "picosat_reset_phases" (picosat @-> returning void)

let reset_scores =
  foreign "picosat_reset_scores" (picosat @-> returning void)

let remove_learned =
  foreign "picosat_remove_learned" (picosat @-> int @-> returning void)

let set_more_important_lit =
  foreign "picosat_set_more_important_lit" (picosat @-> int @-> returning void)

let set_less_important_lit =
  foreign "picosat_set_less_important_lit" (picosat @-> int @-> returning void)

let set_seed =
  foreign "picosat_set_seed" (picosat @-> uint @-> returning void)

let enable_trace_generation =
  foreign "picosat_enable_trace_generation" (picosat @-> returning int)

let save_original_clauses =
  foreign "picosat_save_original_clauses" (picosat @-> returning void)

let inc_max_var =
  foreign "picosat_inc_max_var" (picosat @-> returning int)

let push =
  foreign "picosat_push" (picosat @-> returning int)

let failed_context =
  foreign "picosat_failed_context" (picosat @-> int @-> returning int)

let context =
  foreign "picosat_context" (picosat @-> returning int)

let pop =
  foreign "picosat_pop" (picosat @-> returning int)

let simplify =
  foreign "picosat_simplify" (picosat @-> returning void)

let adjust =
  foreign "picosat_adjust" (picosat @-> int @-> returning void)

let variables =
  foreign "picosat_variables" (picosat @-> returning int)

let added_original_clauses =
  foreign "picosat_added_original_clauses" (picosat @-> returning int)

let max_bytes_allocated =
  foreign "picosat_max_bytes_allocated" (picosat @-> returning size_t)

let time_stamp =
  foreign "picosat_time_stamp" (void @-> returning float)

let stats =
  foreign "picosat_stats" (picosat @-> returning void)

let propagations =
  foreign "picosat_propagations" (picosat @-> returning ullong)

let decisions =
  foreign "picosat_decisions" (picosat @-> returning ullong)

let visits =
  foreign "picosat_visits" (picosat @-> returning ullong)

let seconds =
  foreign "picosat_seconds" (picosat @-> returning double)

let add =
  foreign "picosat_add" (picosat @-> int @-> returning int)

(*
let add_lits =
  foreign "picosat_add_lits" (picosat @-> int @-> returning int)
*)

let assume =
  foreign "picosat_assume" (picosat @-> int @-> returning void)

let add_ado_lit =
  foreign "picosat_add_ado_lit" (picosat @-> int @-> returning void)

let sat' =
  foreign "picosat_sat" (picosat @-> int @-> returning int)

let sat psat limit =
  match sat' psat limit with
  | 10 -> Satisfiable
  | 20 -> Unsatisfiable
  | _ -> Unknown

let set_propagation_limit =
  foreign "picosat_set_propagation_limit"
    (picosat @-> ullong @-> returning void)

let res' =
  foreign "picosat_res" (picosat @-> returning int)

let res psat =
  match res' psat with
  | 10 -> Satisfiable
  | 20 -> Unsatisfiable
  | _ -> Unknown

let deref' =
  foreign "picosat_deref" (picosat @-> int @-> returning int)

let deref psat lit =
  match deref' psat lit with
  | 1 -> Some true
  | -1 -> Some false
  | _ -> None

let deref_toplevel' =
  foreign "picosat_deref_toplevel" (picosat @-> int @-> returning int)

let deref_toplevel psat lit =
  match deref_toplevel' psat lit with
  | 1 -> Some true
  | -1 -> Some false
  | _ -> None

let deref_partial' =
  foreign "picosat_deref_partial" (picosat @-> int @-> returning int)

let deref_partial psat lit =
  match deref_partial' psat lit with
  | 1 -> Some true
  | -1 -> Some false
  | _ -> None

let inconsistent' =
  foreign "picosat_inconsistent" (picosat @-> returning int)

let inconsistent psat =
  if inconsistent' psat = 0 then true
  else false

let failed_assumption' =
  foreign "picosat_failed_assumption" (picosat @-> int @-> returning int)

let failed_assumption psat lit =
  match failed_assumption' psat lit with
  | 0 -> None
  | i -> Some i

let failed_assumptions =
  foreign "picosat_failed_assumptions" (picosat @-> returning string)

let maximal_satisfiable_subset_of_assumptions =
  foreign "picosat_maximal_satisfiable_subset_of_assumptions"
    (picosat @-> returning string)

let next_maximal_satisfiable_subset_of_assumptions =
  foreign "picosat_next_maximal_satisfiable_subset_of_assumptions"
    (picosat @-> returning string)

let next_minimal_correcting_subset_of_assumptions =
  foreign "picosat_next_minimal_correcting_subset_of_assumptions"
    (picosat @-> returning string)

let changed =
  foreign "picosat_changed" (picosat @-> returning int)

let coreclause =
  foreign "picosat_coreclause" (picosat @-> int @-> returning int)

let corelit =
  foreign "picosat_corelit" (picosat @-> int @-> returning int)

let usedlit =
  foreign "picosat_usedlit" (picosat @-> int @-> returning int)

