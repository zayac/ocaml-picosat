(** OCaml bindings to the PicoSAT SAT solver.
   
    Compatible with API version 953. *)

type t = Unknown
       | Satisfiable
       | Unsatisfiable

type picosat = unit Ctypes.ptr
val picosat : picosat Ctypes.typ

val version : unit -> string

val config : unit -> string

val copyright : unit -> string

(** Constructor *)
val init : unit -> picosat

(** Destructor *)
val reset : picosat -> unit

(** Measure all time spent in all calls in the solver.  By default only the
    time spent in [sat] is measured.  Enabling this function may for
    instance triple the time needed to add large CNFs, since every call to
    [add] will trigger a call to [getrusage]. *)
val measure_all_calls : picosat -> unit

(** Set the prefix used for printing verbose messages and statistics.
    Default is "c ". *)
val set_prefix : picosat -> string -> unit

(** Set verbosity level.  A verbosity level of 1 and above prints more and
    more detailed progress reports to stdout.
    Verbose messages are prefixed with the string set by [picosat_set_prefix]. *)
val set_verbosity : picosat -> int -> unit

(** Set default initial phase:

      0 = false
      1 = true
      2 = Jeroslow-Wang (default)
      3 = random initial phase

    After a variable has been assigned the first time, it will always
    be assigned the previous value if it is picked as decision variable.
    The initial assignment can be chosen with this function. *)
val set_global_default_phase : picosat -> int -> unit

(** Set next/initial phase of a particular variable if picked as decision
    variable.  Second argument 'phase' has the following meaning:

      negative = next value if picked as decision variable is false

      positive = next value if picked as decision variable is true

      0        = use global default phase as next value and
                 assume [lit] was never assigned
  
    Again if [lit] is assigned afterwards through a forced assignment,
    then this forced assignment is the next phase if this variable is
    used as decision variable. *)
val set_default_phase_lit : picosat -> int -> int -> unit

(** You can reset all phases by the following function. *)
val reset_phases : picosat -> unit

(** Scores can be erased as well.  Note, however, that even after erasing 
    scores and phases, learned clauses are kept.  In addition head tail
    pointers for literals are not moved either.  So expect a difference
    between calling the solver in incremental mode or with a fresh copy of
    the CNF. *)
val reset_scores : picosat -> unit

(** Reset assignment if in SAT state and then remove the given percentage of
    less active (large) learned clauses.  If you specify 100% all large
    learned clauses are removed. *)
val remove_learned : picosat -> int -> unit

(** Set some variables to be more important than others.  These variables are
    always used as decisions before other variables are used.  Dually there
    is a set of variables that is used last.  The default is
    to mark all variables as being indifferent only. *)
val set_more_important_lit : picosat -> int -> unit
val set_less_important_lit : picosat -> int -> unit

(** Set a seed for the random number generator.  The random number generator
    is currently just used for generating random decisions.  In our
    experiments having random decisions did not really help on industrial
    examples, but was rather helpful to randomize the solver in order to
    do proper benchmarking of different internal parameter sets. *)
val set_seed : picosat -> Unsigned.uint -> unit

(** If you ever want to extract cores or proof traces with the current
    instance of PicoSAT initialized with [init], then make sure to
    call [enable_trace_generation] right after [init].

    NOTE, trace generation code is not necessarily included, e.g. if you
    configure picosat with full optimzation as './configure -O'
    you do not get any results by trying to generate traces.

    The return value is non-zero if code for generating traces is included
    and it is zero if traces can not be generated. *)
val enable_trace_generation : picosat -> int

(** Save original clauses for [deref_partial].  See comments to that function further down. *)
val save_original_clauses : picosat -> unit

(** This function returns the next available unused variable index and
    allocates a variable for it even though this variable does not occur as
    assumption, nor in a clause or any other constraints.  In future calls to
    [sat], [deref] and particularly for [changed],
    this variable is treated as if it had been used. *)
val inc_max_var : picosat -> int

(** Push/pop semantics for PicoSAT.   [push] opens up a new context.
    All clauses added in this context are attached to it and discared when
    the context is closed with [pop].  It is also possible to
    nest contexts.
 
    The current implementation uses a new internal variable for each context.
    However, the indices for these internal variables are shared with
    ordinary external variables.  This means that after any call to
    [push], new variable indices should be obtained with
    [inc_max_var] and not just by incrementing the largest variable
    index used so far.

    The return value is the index of the literal that assumes this context.
    This literal can only be used for [failed_context] otherwise
    it will lead to an API usage error. *)
val push : picosat -> int

(** This is as [failed_assumption], but only for internal variables
    generated by [push]. *)
val failed_context : picosat -> int -> int

(** Returns the literal that assumes the current context or zero if the
    outer context has been reached. *)
val context : picosat -> int

(** Closes the current context and recycles the literal generated for
    assuming this context.  The return value is the literal for the new
    outer context or zero if the outer most context has been reached. *)
val pop : picosat -> int

(** Force immmediate removal of all satisfied clauses and clauses that are
    added or generated in closed contexts.  This function is called
    internally if enough units are learned or after a certain number of
    contexts have been closed.  This number is fixed at compile time
    and defined as [MAXCILS] in 'picosat.c'.
 
    Note that learned clauses which only involve outer contexts are kept. *)
val simplify : picosat -> unit

(** If you know a good estimate on how many variables you are going to use
    then calling this function before adding literals will result in less
    resizing of the variable table.  But this is just a minor optimization.
    Beside exactly allocating enough variables it has the same effect as
    calling [inc_max_var]. *)
val adjust : picosat -> int -> unit

(** {0 Statistics} *)
val variables : picosat -> int (** p cnf <m> n *)
val added_original_clauses : picosat -> int (** p cnf m <n> *)
val max_bytes_allocated : picosat -> Unsigned.size_t
val time_stamp : unit -> float (** ... in progress *)
val stats : picosat -> unit (** > output file *)
val propagations : picosat -> Unsigned.ullong (** #propagations *)
val decisions : picosat -> Unsigned.ullong (** #decisions *)
val visits : picosat -> Unsigned.ullong (** #visits *)

(** The time spent in the library or in [sat].  The former is only
    returned if, right after initialization [measure_all_calls] is called. *)
val seconds : picosat -> float

(** Add a literal of the next clause.  A zero terminates the clause.  The
    solver is incremental.  Adding a new literal will reset the previous
    assignment.   The return value is the original clause index to which
    this literal respectively the trailing zero belong starting at 0. *)
val add : picosat -> int -> int

(* val add_lits : picosat -> int -> int *)

(** You can add arbitrary many assumptions before the next [sat].
    This is similar to the using assumptions in MiniSAT, except that you do
    not have to collect all your assumptions yourself.  In PicoSAT you can
    add one after the other before the next call to [sat].

    These assumptions can be seen as adding unit clauses with those
    assumptions as literals.  However these assumption clauses are only valid
    for exactly the next call to [sat].  And will be removed
    afterwards, e.g. in future calls to [sat] after the next one they
    are not assumed, unless they are assumed again trough [assume].
 
    More precisely, assumptions actually remain valid even after the next
    call to [sat] returns.  Valid means they remain 'assumed' until a
    call to [add], [assume], or another [sat],
    following the first [sat].  They need to stay valid for
    [failed_assumption] to return correct values. *)
val assume : picosat -> int -> unit

(** This is an experimental feature for handling 'all different constraints'
    (ADC).  Currently only one global ADC can be handled.  The bit-width of
    all the bit-vectors entered in this ADC (stored in 'all different
    objects' or ADOs) has to be identical. *)
val add_ado_lit : picosat -> int -> unit

(** Call the main SAT routine.  A negative decision limit sets no limit on
    the number of decisions. *)
val sat : picosat -> int -> t

(** As alternative to a decision limit you can use the number of propagations
    as limit.  This is more linearly related to execution time. This has to
    be called after [init] and before [sat]. *)
val set_propagation_limit : picosat -> Unsigned.ullong -> unit

(** Return last result of calling [sat] or [None] if not called. *)
val res : picosat -> t option

(** After [sat] was called and returned [Satisfiable], then
    the satisfying assignment can be obtained by 'dereferencing' literals.
    The return value is 0 for an unknown value. *)
val deref : picosat -> int -> int

(** Same as before but just returns true resp. false if the literals is
    forced to this assignment at the top level.  This function does not
    require that [sat] was called and also does not internally reset
    incremental usage. *)
val deref_toplevel : picosat -> int -> int

(** After [sat] was called and returned [Satisfiable] a
    partial satisfying assignment can be obtained as well.  It satisfies all
    original clauses.  The value of the literal is return as 1 for 'true', -1
    for 'false' and 0 for an unknown value.  In order to make this work all
    original clauses have to be saved internally, which has to be enabled by
    'picosat_save_original_clauses' right after initialization. *)
val deref_partial : picosat -> int -> int

(** Returns true if the CNF is unsatisfiable because an empty clause was
    added or derived. *)
val inconsistent : picosat -> bool

(** Returns non zero if the literal is a failed assumption, which is defined
    as an assumption used to derive unsatisfiability.  This is as accurate as
    generating core literals, but still of course is an overapproximation of
    the set of assumptions really necessary.  The technique does not need
    clausal core generation nor tracing to be enabled and thus can be much
    more effective.  The function can only be called as long the current
    assumptions are valid.  See [assume] for more details. *)
val failed_assumption : picosat -> int -> int option

(** Returns a zero terminated list of failed assumption in the last call to
    [sat].  The pointer is valid until the next call to
    [sat] or [failed_assumptions].  It only makes sense if the
    last call to [sat] returned [Unsatisfiable]. *)
val failed_assumptions : picosat -> string

(** Compute one maximal subset of satisfiable assumptions.  You need to set
    the assumptions, call [sat] and check for [inconsistent],
    before calling this function.  The result is a zero terminated array of
    assumptions that consistently can be asserted at the same time.  Before
    returing the library 'reassumes' all assumptions.

    It could be beneficial to set the default phase of assumptions
   to true (positive).  This can speed up the computation. *)
val maximal_satisfiable_subset_of_assumptions : picosat -> string

(** This function assumes that you have set up all assumptions with
    [assume].  Then it calls [sat] internally unless the
    formula is already inconsistent without assumptions, i.e.  it contains
    the empty clause.  After that it extracts a maximal satisfiable subset of
    assumptions.

    The result is a zero terminated maximal subset of consistent assumptions
    or a zero pointer if the formula contains the empty clause and thus no
    more maximal consistent subsets of assumptions can be extracted.  In the
    first case, before returning, a blocking clause is added, that rules out
    the result for the next call.

    NOTE: adding the blocking clause changes the CNF.

    It could be beneficial to set the default phase of assumptions
    to true (positive).  This can speed up the computation. *)
val next_maximal_satisfiable_subset_of_assumptions : picosat -> string

(** Similarly we can iterate over all minimal correcting assumption sets.
    See the CAMUS literature {i [M. Liffiton, K. Sakallah JAR 2008]}.
 
    The result contains each assumed literal only once, even if it
    was assumed multiple times (in contrast to the maximal consistent
    subset functions above).
 
    It could be beneficial to set the default phase of assumptions
    to true (positive).  This may speed up the computation. *)
val next_minimal_correcting_subset_of_assumptions : picosat -> string

(** Assume that a previous call to [sat] in incremental usage,
    returned [Satisfiable].  Then a couple of clauses and optionally new
    variables were added (a new variable is a variable that has an index
    larger then the maximum variable added so far).  The next call to
    [sat] also returns [Satisfiable]. If this function
    [changed] returns '0', then the assignment to the old variables
    did not change.  Otherwise it may have changed.   The return value to
    this function is only valid until new clauses are added through
    [add], an assumption is made through [assume], or again
    [sat] is called.  This is the same assumption as for
    [deref]. *)
val changed : picosat -> int

(** {The following functions internally extract the variable and clausal
     core and thus require trace generation to be enabled with
     [enable_trace_generation] right after calling [init].} *)
val coreclause : picosat -> int -> int

(** This function determines whether the i'th added original clause is in the
    core.  The [i] is the return value of [add], which starts at zero
    and is incremented by one after a original clause is added (that is after
    [add 0]).  For the index [i] the following has to hold: 
 
   [0 <= i < added_original_clauses ()] *)
val corelit : picosat -> int -> int

(** Keeping the proof trace around is not necessary if an over-approximation
    of the core is enough.  A literal is 'used' if it was involved in a
    resolution to derive a learned clause.  The core literals are necessarily
    a subset of the 'used' literals. *)
val usedlit : picosat -> int -> int
