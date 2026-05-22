# OCaml Todo CLI

Tasks are saved to `~/.todo.sexp`, like this:

```sexp
((id 1) (title "Buy milk") (status Todo) (priority Medium))
((id 2) (title "Fix bug") (status Done) (priority High))
```

## Build

From the project root:

```sh
dune build
```

This builds the CLI binary at `_build/default/bin/main.exe`.

## Install

Install the executable into your local switch with:

```sh
dune install
```

After that, make sure your switch's `bin` directory is on `PATH`, then you can run:

```sh
todo <args>
```

If you want to run it directly from the build tree instead, use:

```sh
dune exec todo -- <args>
```
