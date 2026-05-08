# P-Lingua — Consolidated Membrane Computing Platform

Unified framework for **P-systems**, **M-systems (Morphogenetic Systems)**, **Relevance Realization**, and **OpenCog AGI** — all expressed as membrane computing models.

Consolidates code and best features from:
- [ReZorg/plingua](https://github.com/ReZorg/plingua) — Core P-Lingua compiler/simulator
- [ReZorg/Cytos](https://github.com/ReZorg/Cytos) — C# M-systems simulator (reference XML examples)
- [ReZorg/RRR-P-Sys-Cog](https://github.com/ReZorg/RRR-P-Sys-Cog) — RR + OpenCog AGI extensions
- [cogpy/rrpling](https://github.com/cogpy/rrpling) — RR-RNN enhanced P-Lingua

## Dependencies

* Linux OS (tested on Ubuntu 16.04+)
* GCC 4.9.0 or higher (with support for regex)
* Flex, Bison
* libboost-filesystem-dev, libboost-program-options-dev

```bash
sudo apt-get install build-essential flex bison libboost-filesystem-dev libboost-program-options-dev
```

## Building

```bash
make grammar      # Generate parser from Flex/Bison
make compiler     # Build bin/plingua (P-Lingua compiler)
make simulator    # Build bin/psim (P-system simulator)
make mcompiler    # Build bin/mlingua (M-Lingua compiler)
make msimulator   # Build bin/msim (M-system simulator)
make extensions   # Build RR/OpenCog demos and tests
make all          # Build everything
sudo make install
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Consolidated P-Lingua                    │
├──────────┬──────────┬──────────────┬────────────────────┤
│ P-Lingua │ M-Lingua │  Relevance   │   OpenCog AGI      │
│  (.pli)  │  (.mli)  │ Realization  │ (AtomSpace, PLN,   │
│          │          │ (RR-RNN)     │  ECAN, MOSES,      │
│ Parser   │ Parser   │              │  OpenPsi, Scheme)  │
│ Compiler │ Compiler │ Hypergraph   │                    │
│ Simulator│ Simulator│ Dynamics     │ Cognitive Cycles   │
├──────────┴──────────┴──────────────┴────────────────────┤
│        Cereal Serialization / Cytos XML Export           │
└─────────────────────────────────────────────────────────┘
```

## P-Lingua Core

Standard membrane computing models: transition, active membranes, tissue, SAT, PDP, SNP.

### Examples

* Existing runnable models: `examples/`
* TODO backlog catalog (by P-system type, application category, complexity): `examples/TODO_EXAMPLES_CATALOG.md`

---

## M-Lingua Extension

M-Lingua (`.mli`) extends P-Lingua with support for **Morphogenetic Systems** — computational models combining membrane computing with spatial geometry and polytopic tile self-assembly (based on Sosík et al. and the [Cytos simulator](https://github.com/ReZorg/Cytos)).

### M-Lingua Features

* `@msystem<morphogenetic>` — Model declaration for M systems
* `@tiling` block — Tile definitions with connectors, glues, and spatial properties
* `@floating` — Floating object definitions with mobility and concentration
* `@protion` — Protein-like markers on tiles
* Rule types: `@create`, `@destroy`, `@divide`, metabolic rules
* Cytos-compatible XML output for Unity visualization

### M-Lingua Examples

| File | Description |
|------|-------------|
| `examples/msystem/boxy_hallows.mli` | Self-replicating boxes |
| `examples/msystem/cytoskeleton.mli` | Eukaryotic cell division |
| `examples/msystem/septum.mli` | Prokaryotic binary fission |
| `examples/msystem/ladder.mli` | Linear self-assembly |
| `examples/msystem/self_healing.mli` | Robust membrane repair |
| `examples/msystem/tissue_morphogenetic.mli` | Tissue-like M system |

### Cytos Reference XML

Original Cytos simulator XML examples in `examples/cytos_xml/` for cross-validation.

See `docs/MLINGUA_SPEC.md` for the full M-Lingua language specification.

---

## Relevance Realization (RR)

Implements the **Agent-Arena-Relation (AAR)** trialectic framework from Vervaeke's Relevance Realization theory as membrane computing dynamics.

### RR Features

* **RR Hypergraph** — Nodes (MEMBRANE, RULE, OBJECT, ENVIRONMENT) with salience, affordance, trialectic state
* **AAR Dynamics** — Agent-Arena-Relation co-constitution with bidirectional coupling
* **Relevance Gradient** — `∇ℜ = log(affordance_realization / affordance_potential)`
* **Emergent Pattern Detection** — High-salience cluster identification
* **AtomSpace Integration** — Bidirectional bridge between RR hypergraph and OpenCog AtomSpace

### RR Examples

| File | Description |
|------|-------------|
| `examples/rr/rr_simple_demo.cpp` | Basic RR dynamics demo |
| `examples/rr/rr_demo.cpp` | Full AAR architecture demo |
| `examples/rr/adaptive_foraging.cpp` | RR-guided foraging simulation |
| `examples/rr/relevance_realization_model.pli` | RR as P-Lingua model |
| `examples/rr/rr_triadic_model.pli` | Trialectic dynamics model |

### RR Binaries

```bash
bin/rr_simple_demo          # Basic RR dynamics
bin/rr_demo                 # Full AAR demo
bin/demo_repl               # Interactive Scheme REPL for RR/AtomSpace
bin/test_rr_enhanced        # RR test suite
bin/test_next_directions    # Extended RR tests
```

---

## OpenCog AGI Integration

Complete OpenCog cognitive architecture expressed as pure P-Lingua membrane computing models with C++ simulation bridges.

### OpenCog Subsystems

| Subsystem | Header | P-Lingua Model | Description |
|-----------|--------|-----------------|-------------|
| **AtomSpace** | `atomspace_integration.hpp` | `opencog_atomspace.pli` | Hypergraph knowledge store |
| **PLN** | `pln_integration.hpp` | `opencog_pln.pli` | Probabilistic Logic Networks |
| **ECAN** | `ecan_integration.hpp` | `opencog_ecan.pli` | Economic Attention Networks |
| **MOSES** | `moses_integration.hpp` | `opencog_moses.pli` | Meta-Optimizing Evolutionary Search |
| **OpenPsi** | `opencog_agi.hpp` | `opencog_openpsi.pli` | Motivational drive system |
| **Unified AGI** | `opencog_agi.hpp` | `opencog_unified_agi.pli` | Full cognitive cycle engine |

### OpenCog Features

* **Perception → Cognition → Action** cognitive cycle
* **PLN Inference** — Deduction, abduction, conjunction, disjunction, implication
* **ECAN Attention** — STI/LTI spreading activation, rent/wage economics, attentional focus
* **MOSES Evolution** — Combo program trees, deme-based evolutionary search, RR-guided feature selection
* **OpenPsi Drives** — Competence, integrity, exploration motivational drives
* **Scheme REPL** — Interactive exploration of RR hypergraph and AtomSpace
* **Persistence** — JSON serialization for AtomSpace and RR hypergraph state

### OpenCog Test Suite

```bash
bin/test_opencog_integration   # 88 tests covering all subsystems
```

---

## Cognitive Cities Architecture Mapping

The platform supports the Cognitive Cities triad architecture:

| Triad | Membrane | Role |
|-------|----------|------|
| **Cerebral** | Cognitive Membrane | Core Processing (thought, processing, output) |
| **Somatic** | Extension Membrane | Plugin Container (motor, sensory, processing) |
| **Autonomic** | Security Membrane | Validation & Control (monitoring, state, triggers) |

---

## Project Structure

```
include/
├── msystem/          # M-Lingua headers (parser, simulator, Cytos XML)
├── parser/           # P-Lingua parser headers
├── simulator/        # P-system simulator headers
├── cereal/           # Serialization library
├── relevance_realization.hpp  # RR hypergraph & AAR dynamics
├── rr_simulator.hpp           # RR-enhanced simulator
├── atomspace_integration.hpp  # OpenCog AtomSpace bridge
├── pln_integration.hpp        # Probabilistic Logic Networks
├── ecan_integration.hpp       # Economic Attention Networks
├── moses_integration.hpp      # MOSES evolutionary search
├── opencog_agi.hpp            # Unified AGI cognitive engine
├── scheme_interface.hpp       # Scheme REPL interface
└── persistent_atomspace.hpp   # JSON persistence

src/
├── parser/           # P-Lingua Flex/Bison parser
├── simulator/        # P-system simulator
├── msystem/          # M-Lingua parser, compiler, simulator
├── rr/               # RR/OpenCog test/demo sources
└── generators/       # Code generators

examples/
├── *.pli             # P-Lingua models (34+ examples)
├── msystem/          # M-Lingua models (6 examples)
├── rr/               # RR demos and models
├── opencog/          # OpenCog P-Lingua models (6 subsystems)
└── cytos_xml/        # Cytos reference XML (8 examples + schema)
```
