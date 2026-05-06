# plingua
The P-Lingua language for Membrane Computing

## Dependencies 

* Linux OS (tested on Ubuntu 16.04 and Ubuntu 18.04)
* GCC 4.9.0 or higher (with support for regex)
* Flex
* Bison
* libboost-filesystem-dev 
* libboost-program-options-dev

sudo apt-get install build-essential flex bison libboost-filesystem-dev libboost-program-options-dev 

## Compiling

* make grammar
* make compiler
* make simulator
* sudo make install

## Examples

* Existing runnable models: `examples/`
* TODO backlog catalog (by P-system type, application category, complexity): `examples/TODO_EXAMPLES_CATALOG.md`

## M-Lingua Extension

M-Lingua (`.mli`) extends P-Lingua with support for **Morphogenetic Systems** — computational models combining membrane computing with spatial geometry and polytopic tile self-assembly.

### Building M-Lingua Tools

```bash
make mcompiler   # builds bin/mlingua (compiler)
make msimulator  # builds bin/msim (simulator)
```

### M-Lingua Features

* `@msystem<morphogenetic>` — Model declaration for M systems
* `@tiling` block — Tile definitions with connectors, glues, and spatial properties
* `@floating` — Floating object definitions with mobility and concentration
* `@protion` — Protein-like markers on tiles
* Rule types: `@create`, `@destroy`, `@divide`, metabolic rules
* Cytos-compatible XML output for visualization

### M-Lingua Examples

* `examples/msystem/boxy_hallows.mli` — Self-replicating boxes
* `examples/msystem/cytoskeleton.mli` — Eukaryotic cell division
* `examples/msystem/septum.mli` — Prokaryotic binary fission
* `examples/msystem/ladder.mli` — Linear self-assembly
* `examples/msystem/self_healing.mli` — Robust membrane repair
* `examples/msystem/tissue_morphogenetic.mli` — Tissue-like M system

See `docs/MLINGUA_SPEC.md` for the full language specification.
