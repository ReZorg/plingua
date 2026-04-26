# Kernel P Systems: Safety and Liveness Queries (kPWorkbench)

## Overview

This document explains how **kP systems** (Kernel P systems) relate to
standard P-Lingua models and how to use the **kPWorkbench** tool for
formal verification of P-system properties.

---

## What are kP Systems?

Kernel P systems (kP systems) are an extension of standard membrane computing
models that unify several P-system variants under a common formalism.  Introduced
by Gheorghe et al. (2013), kP systems feature:

- **Typed membranes**: each membrane carries a type that determines which rule
  categories apply within it (e.g., rewriting, communication, division).
- **Structured topology**: membranes may be organized in arbitrary graph
  structures (not just hierarchical trees or flat tissue arrays).
- **Priority and compartment rules**: rules are associated with priorities and
  compartment types, allowing fine-grained control of parallel execution.

In contrast, standard P-Lingua models use specific model families
(`transition`, `snp`, `membrane_division`, `tissue_division`, `probabilistic`)
with fixed rule templates.  kP systems generalize across these by treating
membrane type as a first-class design parameter.

---

## Formal Verification with kPWorkbench

**kPWorkbench** is an open-source verification environment for kP systems:

> https://github.com/Kernel-P-Systems/kPWorkbench

It supports:

### Safety Properties (LTL / CTL)
Safety properties assert that "something bad never happens":
- Example: *"The predator population never reaches zero before the prey."*
- Expressed in **LTL** (Linear Temporal Logic): `G (predator > 0 -> prey > 0)`
- Or in **CTL** (Computation Tree Logic): `AG (predator > 0 -> prey > 0)`

### Liveness Properties (LTL / CTL)
Liveness properties assert that "something good eventually happens":
- Example: *"The system eventually produces a 'Yes' object (SAT accepted)."*
- LTL: `F (Yes > 0)`
- CTL: `EF (Yes > 0)`

### Reachability Queries
- *"Is there an execution where all nodes become reachable?"*
- CTL: `EF (reach_1 > 0 & reach_2 > 0 & reach_3 > 0 & reach_4 > 0)`

---

## Relationship to P-Lingua Models

P-Lingua (`.pli` files) and kPWorkbench (`.kps` files) target different
levels of the P-systems ecosystem:

| Feature              | P-Lingua                    | kPWorkbench                       |
|----------------------|-----------------------------|-----------------------------------|
| Input format         | `.pli` source files         | `.kps` kP-system specification    |
| Simulation           | `psim` binary               | built-in kPWorkbench simulator    |
| Verification         | not built-in                | LTL/CTL model checking via NuSMV  |
| Model families       | transition, snp, pdp, etc.  | unified kP type system            |
| Parameterization     | `def Sat(m,n)` modules      | parametric compartment types      |

### Workflow: P-Lingua → kPWorkbench

1. Design the P-system in P-Lingua (`.pli`) for rapid prototyping.
2. Compile and simulate with `./bin/plingua` and `./bin/psim`.
3. Translate the verified design to kP-system notation (`.kps`).
4. Use kPWorkbench to:
   - Generate the state space (via the kPWorkbench model checker).
   - Query safety/liveness properties in LTL or CTL.
   - Export counterexamples for debugging.

---

## Example Query Workflow (kPWorkbench)

```bash
# Clone and build kPWorkbench
git clone https://github.com/Kernel-P-Systems/kPWorkbench
cd kPWorkbench && mvn package

# Verify a kP-system model
java -jar kPWorkbench.jar --model sat_model.kps --property "EF (Yes > 0)"
```

---

## References

- Gheorghe, M., Ceterchi, R., Ipate, F., Konur, S., Lefticaru, R. (2013).
  "Kernel P systems: From informal description to a formal definition."
  *Proc. 11th Brainstorming Week on Membrane Computing*, 81–124.

- Konur, S., Gheorghe, M., Dragomir, C., Ipate, F., Bakir, M.E. (2016).
  "Property-driven systematic analysis of membrane systems using kPWorkbench."
  *Journal of Membrane Computing* 1(2).

- kPWorkbench repository: https://github.com/Kernel-P-Systems/kPWorkbench

- P-Lingua project: http://www.p-lingua.org
