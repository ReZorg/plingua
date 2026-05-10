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
* Geometry extensions: `@geometry`, `@manifold`, `@metric`, `@connection`
* Advanced model directives: `@polytope`, `@flow`, `@capability`
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
| `examples/msystem/geometry_120cell.mli` | Geometry-profile + 120-cell metadata example |

### Cytos Reference XML

Original Cytos simulator XML examples in `examples/cytos_xml/` for cross-validation.

See `docs/MLINGUA_SPEC.md` for the full M-Lingua language specification.

---

## R-Lingua (Relevance Lingua, `.rli`)

R-Lingua is the **Relevance Realization DSL** — a language extension focused on Vervaeke's Relevance Realization theory with the **trielectic ennead architecture**.  It sits alongside P-Lingua (`.pli`) and M-Lingua (`.mli`) without changing either existing pipeline.

### Core Concepts

| Concept | Description |
|---------|-------------|
| **Trielectic ennead** | 9 dimensions across 3 triads (Agent, Arena, Relation) |
| **Grip index** | Per-node measure of optimal cognitive grip ∈ [0,1] |
| **Ennead balance** | How evenly the 9 dimensions contribute (high = stable) |
| **Relevance gradient** | ∇ℜ = log(affordance_realization / affordance_potential) |
| **Emergence score** | Fraction of nodes that have achieved emergent relation status |

### Ennead Triads

| Triad | Pole | Dimensions |
|-------|------|------------|
| **A** | Agent | identity_continuity, skill_readiness, motivational_valence |
| **B** | Arena | constraint_clarity, affordance_density, feedback_latency |
| **C** | Relation | coupling_strength, reciprocal_shaping, adaptive_fit |

### Build

```bash
# Compiler binary
make rcompiler           # produces bin/rlingua

# Run unit + integration tests
make bin/test_rlingua
./bin/test_rlingua       # 73 tests
```

### Usage

```bash
# Compile and run 50 RR dynamics steps on a .rli model
bin/rlingua examples/rr/minimal_ennead.rli -s 50 -v -o report.json

# Options:
#   -s <steps>   Run N dynamics steps (default: 0)
#   -o <file>    Output JSON grip report (default: stdout)
#   -v           Verbose per-step output
#   -h           Help
```

### R-Lingua Examples

| File | Description |
|------|-------------|
| `examples/rr/minimal_ennead.rli` | Minimal single agent–arena model with balanced ennead |
| `examples/rr/adaptive_coupling.rli` | Two-arena adaptive coupling (grip_index improvement demo) |
| `examples/rr/convergence_benchmark.rli` | Symmetric 2-agent 2-arena convergence benchmark |

### Minimal `.rli` Model

```rli
@rmodel<relevance_realization>

@ennead {
    @triad_a { identity_continuity=0.7; skill_readiness=0.6; motivational_valence=0.8; }
    @triad_b { constraint_clarity=0.5; affordance_density=0.9; feedback_latency=0.3; }
    @triad_c { coupling_strength=0.7; reciprocal_shaping=0.6; adaptive_fit=0.5; }
}

@constraints { grip_threshold=0.3; emergence_sensitivity=0.75; convergence_window=50; }

def main() {
    @agent id=a1 label="agent" salience=0.8 affordance=1.0;
    @arena id=e1 label="arena" salience=0.6 affordance=1.2;
    @coupling { a1 <-> e1 :: co_constitution strength=0.8; }
}

@observe { sample_period=10; report_fields=grip_index, ennead_balance; }
```

See `docs/RLINGUA_SPEC.md` for the full R-Lingua language specification.

### Migration: Existing RR Code → R-Lingua

| Old construct | R-Lingua equivalent |
|---------------|---------------------|
| `AARType::AGENT` node | `@agent` declaration |
| `AARType::ARENA` node | `@arena` declaration |
| `RREdge::CO_CONSTRUCTION` | `<->` coupling rule |
| `trialectic_state[0,1,2]` | `@triad_a` ennead dimensions |
| `computeTrialecticCoherence()` | `coherence` field (auto-computed) |
| `detectEmergentPatterns()` | Driven by `@emergence_trigger` / `emergence_sensitivity` |

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
├── rlingua/          # R-Lingua headers (rli_parser.hpp)
├── parser/           # P-Lingua parser headers
├── simulator/        # P-system simulator headers
├── cereal/           # Serialization library
├── relevance_realization.hpp  # RR hypergraph, ennead state, grip metrics
├── rr_simulator.hpp           # RR-enhanced simulator
├── atomspace_integration.hpp  # OpenCog AtomSpace bridge + ennead projection
├── pln_integration.hpp        # Probabilistic Logic Networks
├── ecan_integration.hpp       # Economic Attention Networks
├── moses_integration.hpp      # MOSES evolutionary search
├── opencog_agi.hpp            # Unified AGI cognitive engine
├── scheme_interface.hpp       # Scheme REPL interface + ennead/grip commands
└── persistent_atomspace.hpp   # JSON persistence + ennead state

src/
├── parser/           # P-Lingua Flex/Bison parser
├── simulator/        # P-system simulator
├── msystem/          # M-Lingua parser, compiler, simulator
├── rlingua/          # R-Lingua parser (rli_parser.cpp, rlingua_main.cpp)
├── rr/               # RR/OpenCog test/demo sources
└── generators/       # Code generators

examples/
├── *.pli             # P-Lingua models (34+ examples)
├── msystem/          # M-Lingua models (6 examples)
├── rr/               # RR demos and models
├── opencog/          # OpenCog P-Lingua models (6 subsystems)
├── skin/             # Multiscale cosmeceutical skin model (phases 1–5)
│   ├── conditions/   # Condition-specific variants (6 conditions × 3 severities)
│   │   ├── atopic_dermatitis/  # AD barrier defect + Th2 inflammatory model
│   │   ├── acne/               # Sebaceous + innate inflammatory model
│   │   ├── psoriasis/          # Hyperproliferative + Th17 inflammatory model
│   │   ├── rosacea/            # Neurovascular + innate inflammatory model
│   │   ├── hyperpigmentation/  # Melanogenesis + melanosome transfer model
│   │   └── photoaging/         # MMP/ECM + oxidative stress model
│   └── actives/      # CBD, retinol, niacinamide, AHA active modules
└── cytos_xml/        # Cytos reference XML (8 examples + schema)
```

### Skin Condition Models

Six clinically validated skin conditions are modeled as parameterized perturbations
of the healthy multiscale skin baseline.  Each condition implements **mild / moderate
/ severe** severity tiers and maps to the appropriate DSL phases:

| Condition | Pathophysiology | Primary agents | Key model files |
|-----------|----------------|----------------|-----------------|
| Atopic Dermatitis | Barrier defect + Th2 inflammatory | CBD, Niacinamide | `ad_barrier_*.pli`, `ad_biology_*.mli`, `ad_rr.rli` |
| Acne | Sebaceous + innate inflammatory | CBD, AHA | `acne_sebaceous_*.mli`, `acne_rr.rli` |
| Psoriasis | Hyperproliferative + Th17 | Retinol, Niacinamide | `pso_barrier_*.pli`, `pso_biology_*.mli`, `pso_rr.rli` |
| Rosacea | Neurovascular + innate inflammatory | CBD, Niacinamide | `rosa_inflammatory_*.mli`, `rosa_rr.rli` |
| Hyperpigmentation | Melanogenesis + melanosome transfer | Niacinamide, AHA | `hyper_melanogenesis_*.mli`, `hyper_rr.rli` |
| Photoaging | MMP/ECM + oxidative stress | Retinol, Niacinamide | `photo_mmp_*.mli`, `photo_rr.rli` |

See `docs/SKIN_CONDITIONS_SPEC.md` for the full condition profile schema and
`examples/skin/conditions/EXPERIMENT_MATRIX.md` for the cross-condition runbook.
