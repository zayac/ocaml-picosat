The package provides OCaml bindings to the industrial-strength
[PicoSAT](http://fmv.jku.at/picosat/) SAT solver.

The bindings are compatible with API version 953.

The package also contains a wrapper over PicoSAT that allows to provide the
initial problem as a arbitrary logical formula (not CNF). Furthermore, the
solver is able to produce all solutions (models) instead of a single one.

## Usage

The package requires PicoSAT library. A linker should be able to access it via
`-lpicologic` flag. 

The bindings extensively uses OCaml
[ctypes](https://github.com/ocamllabs/ocaml-ctypes) library, which must present
in the system.

Installation details can be found in
[INSTALL.txt](https://github.com/zayac/ocaml-picosat/blob/master/INSTALL.txt)
file.

### PicoSAT library installation details

#### OS X

The library may be installed from an unofficial Homebrew repository:
https://github.com/mht208/homebrew-formal

#### Ubuntu

PicoSAT for Ubuntu is accessible from the official repository:

```
apt-get install picosat
```

## Example

### PicoSAT

[This](https://github.com/zayac/ocaml-picosat/blob/master/lib_test/test_solver.ml)
example is taken from the slides ["Using High Performance SAT and QBF
Solvers"](http://fmv.jku.at/biere/talks/Biere-TPTPA11.pdf) and adopted to be
used with the bindings.

```ocaml
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
```

### Logic

In this example the initial formula is provided in an arbitrary form. The
solver finds and prints all possible assignments for the variables.

```ocaml
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
```

## Contribution

Everyone is more than welcome to contact regarding issues and suggestions.
