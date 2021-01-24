# runTimeLimit

## Short Description

Runs function thunks with time limits

## Documentation

The documentation for the `RunTimeLimit` module is present here: [RunTimeLimit documentation](https://nik312123.github.io/ocamlLibDocs/runTimeLimit/RunTimeLimit/).

## Installation

There are a few ways in which you can use this package:

### Using it only in your local project

Clone this repository in your workspace directory where the workspace path is `[workspace_path]`:

```bash
cd [workspace_path]
git clone https://github.com/nik312123/runTimeLimit.git
```

**1\. If your project is a dune project:**

Dune projects are currently not supported (see [dune issue 4151](https://github.com/ocaml/dune/issues/4151))

**2\. If your project is built using `ocamlbuild`**

When building using `ocamlbuild`, include the library directory in the locations to search for dependencies, and include the `Unix` library

Example:

If `[example_path]` is the path for `example.ml` and `[runTimeLimit_path]` is the path for `runTimeLimit.ml` where both paths are subdirectories of the workspace directory, then the following would be the command to build `example.byte` using the `RunTimeLimit` module:

```bash
ocamlbuild -lib unix -use-ocamlfind -I [example_path] -I [runTimeLimit_path] example.byte
```

### Installing it in your `opam` switch and using it in a project

Clone the repository wherever you would like:

```bash
git clone https://github.com/nik312123/runTimeLimit.git
```

Go into the directory you just cloned:

```bash
cd runTimeLimit
```

Install the library using `opam`:

```bash
opam install .
```

**1\. If your project is a dune project:**

Dune projects are currently not supported (see [dune issue 4151](https://github.com/ocaml/dune/issues/4151))

**2\. If your project is built using `ocamlbuild`**

When building using `ocamlbuild`, include the library in your packages, and include the `Unix` library.

```bash
ocamlbuild -lib unix -pkgs runTimeLimit example.byte
```

## Terms of Use

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

Please review [COPYING](COPYING) and [COPYING.LESSER](COPYING.LESSER) to understand the terms of use.
