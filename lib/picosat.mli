type t = Unknown | Satisfiable | Unsatisfiable
type picosat = unit Ctypes.ptr
val picosat : picosat Ctypes.typ
val version : unit -> string
val config : unit -> string
val copyright : unit -> string
val init : unit -> picosat
val reset : picosat -> unit
val measure_all_calls : picosat -> unit
val set_prefix : picosat -> string -> unit
val set_verbosity : picosat -> int -> unit
val set_plain : picosat -> int -> unit
val set_global_default_phase : picosat -> int -> unit
val set_default_phase_lit : picosat -> int -> int -> unit
val reset_phases : picosat -> unit
val reset_scores : picosat -> unit
val remove_learned : picosat -> int -> unit
val set_more_important_lit : picosat -> int -> unit
val set_less_important_lit : picosat -> int -> unit
val set_seed : picosat -> Unsigned.uint -> unit
val enable_trace_generation : picosat -> int
val save_original_clauses : picosat -> unit
val inc_max_var : picosat -> int
val push : picosat -> int
val failed_context : picosat -> int -> int
val context : picosat -> int
val pop : picosat -> int
val simplify : picosat -> unit
val adjust : picosat -> int -> unit
val variables : picosat -> int
val added_original_clauses : picosat -> int
val max_bytes_allocated : picosat -> Unsigned.size_t
val time_stamp : unit -> float
val stats : picosat -> unit
val propagations : picosat -> Unsigned.ullong
val decisions : picosat -> Unsigned.ullong
val visits : picosat -> Unsigned.ullong
val seconds : picosat -> float
val add : picosat -> int -> int
(* val add_lits : picosat -> int -> int *)
val assume : picosat -> int -> unit
val add_ado_lit : picosat -> int -> unit
val sat' : picosat -> int -> int
val sat : picosat -> int -> t
val set_propagation_limit : picosat -> Unsigned.ullong -> unit
val res' : picosat -> int
val res : picosat -> t
val deref' : picosat -> int -> int
val deref : picosat -> int -> bool option
val deref_toplevel' : picosat -> int -> int
val deref_toplevel : picosat -> int -> bool option
val deref_partial' : picosat -> int -> int
val deref_partial : picosat -> int -> bool option
val inconsistent' : picosat -> int
val inconsistent : picosat -> bool
val failed_assumption' : picosat -> int -> int
val failed_assumption : picosat -> int -> int option
val failed_assumptions : picosat -> string
val maximal_satisfiable_subset_of_assumptions : picosat -> string
val next_maximal_satisfiable_subset_of_assumptions : picosat -> string
val next_minimal_correcting_subset_of_assumptions : picosat -> string
val changed : picosat -> int
val coreclause : picosat -> int -> int
val corelit : picosat -> int -> int
val usedlit : picosat -> int -> int
