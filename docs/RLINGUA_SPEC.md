# R-Lingua Specification (`.rli`)

## Overview

R-Lingua (Relevance Lingua, `.rli`) is a domain-specific language for
**Relevance Realization (RR)** systems built on the
**trielectic ennead** architecture derived from John Vervaeke's Relevance
Realization theory.

R-Lingua is a strict superset of P-Lingua (`.pli`): every valid `.pli` file is
also a valid `.rli` file.  The `.rli` extension adds first-class constructs for:

* Declaring the three trielectic triads and their nine ennead dimensions
* Specifying coupling rules between Agent, Arena, and Relation nodes
* Setting optimization constraints and convergence criteria
* Reporting/observability annotations for grip diagnostics

**Core goal**: *optimal cognitive grip* — maximising actionable relevance while
minimising noise and instability in the agent-arena-relation dynamic.

---

## Theoretical Basis

### Relevance Realization (Vervaeke)

Relevance Realization is the pre-reflective process by which a cognitive agent
continuously sculpts its own problem space to retain only the information and
affordances that matter for current concerns.  It is not itself a deliberate
computation; it is the condition of possibility for all deliberate computation.

Mathematically:

```
∇ℜ = lim_{t→∞} Σᵢ log(affordance_realizationᵢ(t) / affordance_potentialᵢ(t))
```

### Trielectic Ennead Architecture

A *trielectic* system has three mutually co-constituting poles rather than two
opposing ones.  An *ennead* assigns exactly **three dimensions to each pole**,
yielding nine total dimensions.  The three poles are:

| Pole | Name     | AAR Role  |
|------|----------|-----------|
| A    | Agent    | AGENT     |
| B    | Arena    | ARENA     |
| C    | Relation | RELATION  |

The nine ennead dimensions and their semantics:

| Pole | Index | Name                    | Meaning                                          |
|------|-------|-------------------------|--------------------------------------------------|
| A    | 0     | identity_continuity     | Degree to which the agent maintains stable self-model |
| A    | 1     | skill_readiness         | Availability of action schemas for current demands |
| A    | 2     | motivational_valence    | Strength and directionality of goal gradient     |
| B    | 3     | constraint_clarity      | Degree to which arena rules are legible          |
| B    | 4     | affordance_density      | Richness of actionable possibilities in arena    |
| B    | 5     | feedback_latency        | Inverse speed of consequence signals from arena  |
| C    | 6     | coupling_strength       | Intensity of mutual agent-arena influence        |
| C    | 7     | reciprocal_shaping      | Degree to which agent and arena co-constitute    |
| C    | 8     | adaptive_fit            | Current alignment between agent skills and arena affordances |

### Grip Index

The *grip index* for a node quantifies how well the node is contributing to
optimal cognitive grip:

```
grip_index = (affordance_realization / affordance_potential)
           × coherence
           × ennead_balance
```

Where `ennead_balance ∈ [0,1]` measures how evenly the nine ennead dimensions
are contributing (low variance ⇒ high balance).

### Global Objective Metrics

| Metric             | Definition                                                       |
|--------------------|------------------------------------------------------------------|
| `relevance_gradient` | Mean ∇ℜ across all nodes                                     |
| `ennead_balance`   | System-wide ennead balance (mean of per-node balance)           |
| `grip_stability`   | Variance of grip_index over recent time window (lower = better) |
| `emergence_score`  | Count of active emergent relation nodes / total nodes           |

---

## Formal Definition

An R-Lingua system `R = (E, N, C, Ω, Γ)` where:

* **E = (a, b, c)**: Ennead triads — Agent (a₀,a₁,a₂), Arena (b₀,b₁,b₂), Relation (c₀,c₁,c₂)
* **N**: Set of RR nodes with per-node metrics (salience, affordance, coherence, grip_index)
* **C**: Set of coupling rules with directionality and strength constraints
* **Ω**: Optimization constraints (thresholds, decay rates, convergence criteria)
* **Γ**: Observability/reporting block (sampling period, output fields)

---

## New Keywords

| Keyword | Description |
|---------|-------------|
| `@rmodel` | Declares an R-Lingua model |
| `@ennead` | Defines the nine-dimensional ennead initial state |
| `@triad_a` | Agent triad initial values |
| `@triad_b` | Arena triad initial values |
| `@triad_c` | Relation triad initial values |
| `@coupling` | Coupling rule declaration |
| `@constraints` | Optimization / convergence constraint block |
| `@observe` | Observability / reporting block |
| `@grip_threshold` | Minimum acceptable grip_index before triggering alert |
| `@emergence_trigger` | Conditions for emergent relation creation |

---

## Syntax

### Model Header

```rli
@rmodel<relevance_realization>
```

The model identifier `relevance_realization` is mandatory.  Future variants may
use `relevance_realization_hierarchical`, `relevance_realization_temporal`, etc.

### Ennead Block

```rli
@ennead {
    @triad_a {
        identity_continuity  = 0.7;
        skill_readiness      = 0.6;
        motivational_valence = 0.8;
    }
    @triad_b {
        constraint_clarity = 0.5;
        affordance_density = 0.9;
        feedback_latency   = 0.3;
    }
    @triad_c {
        coupling_strength  = 0.7;
        reciprocal_shaping = 0.6;
        adaptive_fit       = 0.5;
    }
}
```

All nine values must be in `[0, 1]`.  Missing values default to `0.5`.

### Node Declaration (inside `def main()`)

```rli
@agent  id=agent_1  label="forager"    salience=0.8  affordance=1.2;
@arena  id=arena_1  label="forest"     salience=0.6  affordance=1.0;
@relate id=rel_1    from=agent_1 to=arena_1 strength=0.7;
```

Nodes declared with `@agent` are assigned AARType::AGENT; with `@arena` →
AARType::ARENA; with `@relate` → AARType::RELATION.

### Coupling Rules

```rli
@coupling {
    agent_1 <-> arena_1  :: co_constitution  strength=0.8;
    agent_1 ->  arena_1  :: application      strength=0.5;
}
```

Arrow semantics:
* `<->` — bidirectional CO_CONSTRUCTION coupling
* `->` — unidirectional APPLICATION coupling
* `~>` — emergent EMERGENT coupling (generated automatically on trigger)

### Constraints Block

```rli
@constraints {
    salience_threshold    = 0.05;   /* nodes below this are pruned  */
    affordance_decay      = 0.02;   /* per-step affordance decay    */
    grip_threshold        = 0.3;    /* minimum grip_index           */
    convergence_window    = 50;     /* steps for stability check    */
    emergence_sensitivity = 0.7;    /* coupling threshold for emergence */
}
```

### Observability Block

```rli
@observe {
    sample_period = 10;
    report_fields = grip_index, ennead_balance, relevance_gradient;
}
```

---

## Semantics

### Initialization

1. Parse ennead block; populate `EnneadState` for the system.
2. Declare nodes; assign initial salience/affordance from node declarations.
3. Apply coupling rules; populate hypergraph edges.
4. Set constraint parameters.

### Update Order (per step)

1. **Ennead update**: propagate trielectic co-constitution within each triad
   (circular coupling A₀→A₁→A₂→A₀, B₀→B₁→B₂→B₀, C₀→C₁→C₂→C₀) and
   cross-triad coupling A↔B↔C↔A.
2. **Salience update**: incorporate ennead feedback into per-node salience using
   the ennead balance term.
3. **Affordance update**: apply affordance decay; update realization from
   co-construction dynamics.
4. **Grip computation**: compute per-node grip_index, global ennead_balance,
   grip_stability, emergence_score.
5. **Emergence detection**: if coupling_strength of any agent-arena pair exceeds
   `emergence_sensitivity` and coherence > `grip_threshold`, spawn a new
   RELATION node.
6. **Pruning**: remove nodes whose salience drops below `salience_threshold`.
7. **Observability**: emit report fields if `step % sample_period == 0`.

### Convergence Criterion

The system is considered converged when `grip_stability < 0.01` over a window
of `convergence_window` consecutive steps and `ennead_balance > 0.8`.

### Boundedness Invariants

All per-node values must remain in valid ranges after each step:

| Field                   | Valid range |
|-------------------------|-------------|
| `salience`              | [0, 1]      |
| `affordance_potential`  | (0, ∞)      |
| `affordance_realization`| [0, ∞)      |
| `coherence`             | [0, 1]      |
| `grip_index`            | [0, 1]      |
| ennead dimensions       | [0, 1]      |

Any value that would exceed its range is clamped.

---

## Example: Minimal Ennead Model

```rli
@rmodel<relevance_realization>

@ennead {
    @triad_a { identity_continuity=0.7; skill_readiness=0.6; motivational_valence=0.8; }
    @triad_b { constraint_clarity=0.5; affordance_density=0.9; feedback_latency=0.3; }
    @triad_c { coupling_strength=0.7; reciprocal_shaping=0.6; adaptive_fit=0.5; }
}

@constraints {
    grip_threshold        = 0.3;
    emergence_sensitivity = 0.7;
    convergence_window    = 50;
}

def main() {
    @agent id=agent_1  label="agent"   salience=0.8 affordance=1.0;
    @arena id=arena_1  label="arena"   salience=0.6 affordance=1.2;
    @coupling { agent_1 <-> arena_1 :: co_constitution strength=0.8; }
}

@observe { sample_period=10; report_fields=grip_index, ennead_balance; }
```

---

## Relation to P-Lingua and M-Lingua

| Feature                | P-Lingua (`.pli`) | M-Lingua (`.mli`) | R-Lingua (`.rli`) |
|------------------------|-------------------|-------------------|-------------------|
| Core construct         | Membrane rules    | Tiles + geometry  | RR nodes + ennead |
| Model declaration      | `@model`          | `@msystem`        | `@rmodel`         |
| Compiler binary        | `plingua`         | `mlingua`         | `rlingua`         |
| Simulator binary       | `psim`            | `msim`            | `rsim`            |
| Primary output         | JSON/XML/binary   | Cytos XML         | JSON + grip report|

---

## Migration: Existing RR Demos → R-Lingua

| Old demo concept              | R-Lingua equivalent                                |
|-------------------------------|----------------------------------------------------|
| `AARType::AGENT` node         | `@agent` declaration                               |
| `AARType::ARENA` node         | `@arena` declaration                               |
| `RREdge::CO_CONSTRUCTION`     | `<->` coupling rule                                |
| `trialectic_state[0,1,2]`     | `@triad_a` ennead dimensions                       |
| `computeTrialecticCoherence()`| Automatic coherence field on every node            |
| `detectEmergentPatterns()`    | Triggered by `@emergence_trigger` block            |

---

## Authoring Checklist

Before submitting an R-Lingua model, verify:

- [ ] `@rmodel<relevance_realization>` is present and first.
- [ ] `@ennead` block declares all nine dimensions (or relies on defaults).
- [ ] Every `@agent` and `@arena` node has a unique `id`.
- [ ] At least one `@coupling` rule connects an agent to an arena.
- [ ] `grip_threshold > 0` in `@constraints`.
- [ ] `convergence_window >= 10` in `@constraints`.
- [ ] `@observe` block is present (even if minimal).
- [ ] All ennead dimension initial values are in `[0, 1]`.
- [ ] No coupling `strength` exceeds `1.0`.
