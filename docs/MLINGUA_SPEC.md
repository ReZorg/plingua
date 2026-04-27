# M-Lingua Specification (`.mli`)

## Overview

M-Lingua is a domain-specific language for **Morphogenetic Systems (M systems)**,
extending P-Lingua (`.pli`) for membrane computing with spatial geometry, tile
self-assembly, and morphogenetic processes.

M-Lingua is a strict superset of P-Lingua: every valid `.pli` file is also a
valid `.mli` file. The `.mli` extension adds constructs for defining tiles,
connectors, glues, protions, floating objects with spatial properties, and
M-system-specific rule types (creation, destruction, division, metabolic).

## Formal Definition

An M system `M = (F, P, T, μ, R, σ)` where:

- **F = (O, m, ρ, ε)**: Catalog of floating objects with mobility, radius, concentration
- **P**: Set of protions (analogous to proteins on membranes)
- **T = (Q, G, γ, dg, S)**: Polytopic tile system
- **μ**: Mapping of protions to positions on tiles
- **R**: Finite set of reaction rules
- **σ**: Glue-pair to floating-object release mapping

## New Keywords

| Keyword | Description |
|---------|-------------|
| `@msystem` | Declares an M system model |
| `@tiling` | Defines the polytopic tile system |
| `@tile` | Defines a tile (polytope) |
| `@connector` | Defines a connector on a tile |
| `@glue` | Defines a glue |
| `@glue_relation` | Defines which glues can bind |
| `@protion` | Defines a protion (protein-like object) |
| `@floating` | Defines a floating object catalog |
| `@seed` | Defines seed tiles |
| `@glue_radius` | Gluing distance |
| `@sigma` | Glue-pair release mapping |

## Rule Types

### Metabolic Rules (from P-Lingua, extended)

```
// Simple
u --> v;

// Catalytic (protion-mediated)
p: u --> v;

// Symport (in)
u [| p --> [| p u;

// Symport (out)
[| p u --> u [| p;

// Antiport
u [| p v --> v [| p u;
```

### Creation Rules

```
// Floating objects create a tile
@create u --> t;
```

### Destruction Rules

```
// Consume tile and floating objects, produce floating objects
@destroy u, t --> v;
```

### Division Rules

```
// Disconnect two tiles at glue pair
@divide g1, u, g2 --> g1, g2;
```

## Tile Definition Syntax

```mli
@tile name(sides=N, radius=R) {
    @connector c1(vertices=[v1,v2], glue=g1, angle=90);
    @connector c2(vertices=[v2,v3], glue=g1, angle=90);
    @surface_glue gx;
    @color Blue alpha=128;
    @protion p1 at (x, y);
}
```

## Full Example: Boxy Hallows

```mli
@msystem<morphogenetic>

@tiling {
    @glue g1;
    @glue gx;
    @glue_relation(g1, g1);
    @glue_radius 0.1;

    @tile d(sides=4, radius=2) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=90);
        @connector c2(vertices=[v2,v3], glue=g1, angle=90);
        @connector c3(vertices=[v3,v4], glue=g1, angle=90);
        @connector c4(vertices=[v4,v1], glue=g1, angle=90);
        @surface_glue gx;
        @color Blue alpha=128;
    }

    @seed d at (0, 0, 0);
}

@floating a(mobility=5, radius=0.05, concentration=10);

def main() {
    @create a --> d;
    @divide g1, a, g1 --> g1, g1;
}
```

## Relation to Cytos XML

M-Lingua `.mli` files can be compiled to Cytos-compatible XML for simulation
in the Cytos/Unity visualization engine, or simulated directly by `msim`.

| M-Lingua | Cytos XML |
|----------|-----------|
| `@tile` | `<tile>` |
| `@connector` | `<connector>` |
| `@glue_relation` | `<glueTuple>` |
| `@floating` | `<floatingObject>` |
| `@protion` | `<protein>` |
| `@create` | `<evoRule type="Create">` |
| `@destroy` | `<evoRule type="Destroy">` |
| `@divide` | `<evoRule type="Divide">` |

## Model Types

- `@msystem<morphogenetic>` — Full M system with tiles and spatial geometry
- `@msystem<tissue_morphogenetic>` — Tissue-like M system with graph topology
- `@model<transition>` — Standard P-Lingua transition (backward compatible)
- `@model<probabilistic>` — Standard P-Lingua probabilistic (backward compatible)
