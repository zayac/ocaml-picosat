(** A wrapper over PicoSAT to ease solution of a SAT problem.  Boolean formulas
    can be provided in an arbitrary form (not CNF).  The solver can find all
    models instead of a single one. *)

(** Basic representation of a boolean formula. *)
type t =
  | False
  | True
  | Not of t
  | Or of t * t
  | And of t * t
  | Var of string

(** Boolean formula string representation. *)
val to_string : t -> string

(** Reduce boolean formula.  Unnecessary [True], [False] terms are removed from
    the formula, double negations are removed. *)
val simplify : t -> t

(** Convert formula to Conjunctive Normal Form (CNF).  Returns a list of
    conjunctions.  A formula is simplified before conversion. *)
val to_cnf : t -> t list list

(** Find all assignments to variables in a conjunction of formulas in the list.
    In case of satisfiability, the result is a list of all possible solutions,
    i.e. a solution is a list of variable-value pairs, otherwise the result is
    [None].
    *)
val all_solutions : t list -> (string * bool) list list option

(** Find only a single (any) assignment for all variables.  In case of
    satisfiability, the result is a list of variable-value pairs, otherwise the
    result is [None]. *)
val solve : t list -> (string * bool) list option

(** {2 Logical operators } *)

(** Disjunction *)
val ( + ) : t -> t -> t

(** Conjunction *)
val ( * ) : t -> t -> t

(** Negation *)
val ( ~- ) : t -> t

(** Implication *)
val ( ==> ) : t -> t -> t

(** Converse implication *)
val ( <== ) : t -> t -> t

(** Equivalence *)
val ( <=> ) : t -> t -> t

