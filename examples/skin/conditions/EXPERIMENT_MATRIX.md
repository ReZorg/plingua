# Skin Conditions — Experiment Matrix

This document defines the **canonical experiment matrix** for the multiscale skin
condition models.  Each cell specifies which model files to link, expected output
directions, and the shell command to reproduce the run.

---

## 1. Matrix Definition

| Condition | Severity | CBD oil | Retinol lipo | Niacinamide gel | AHA gel |
|-----------|----------|---------|--------------|-----------------|---------|
| **AD**    | mild     | ✓ primary | — | ✓ secondary | ✗ (contraindicated) |
| **AD**    | moderate | ✓ primary | — | ✓ secondary | ✗ |
| **AD**    | severe   | ✓ primary | — | ✓ secondary | ✗ |
| **Acne**  | mild     | ✓ primary | — | — | ✓ secondary |
| **Acne**  | moderate | ✓ primary | — | — | ✓ secondary |
| **Acne**  | severe   | ✓ primary | — | — | ✓ secondary |
| **PSO**   | mild     | — | ✓ primary | ✓ secondary | — |
| **PSO**   | moderate | — | ✓ primary | ✓ secondary | — |
| **PSO**   | severe   | — | ✓ primary | ✓ secondary | — |
| **Rosacea** | mild   | ✓ primary | — | ✓ secondary | ✗ |
| **Rosacea** | moderate | ✓ primary | — | ✓ secondary | ✗ |
| **Rosacea** | severe | ✓ primary | — | ✓ secondary | ✗ |
| **HYP**   | mild     | — | — | ✓ primary | ✓ secondary |
| **HYP**   | moderate | — | — | ✓ primary | ✓ secondary |
| **HYP**   | severe   | — | — | ✓ primary | ✓ secondary |
| **PAG**   | mild     | — | ✓ primary | ✓ secondary | — |
| **PAG**   | moderate | — | ✓ primary | ✓ secondary | — |
| **PAG**   | severe   | — | ✓ primary | ✓ secondary | — |

**Legend:** ✓ = formulation included; ✗ = contraindicated; — = not primary indication

---

## 2. Phase-Linked Model Paths

For each matrix cell, the four phase files to link are:

| Phase | Role | Template |
|-------|------|----------|
| 1 (`.pli`) | Barrier permeability | `<cond>/<cond>_barrier_<sev>.pli` (AD, PSO) |
| 3/4 (`.mli`) | Tissue/cell biology | `<cond>/<cond>_<module>_<sev>.mli` (all) |
| 5 (`.rli`) | R-Lingua grip | `<cond>/<cond>_rr.rli` (one per condition) |
| 6 (`.pli`) | PBPK safety | `examples/opencog/skin_pbpk.pli` (shared) |

---

## 3. Per-Cell Run Commands

### 3.1 Atopic Dermatitis — All Severities

```bash
COND=atopic_dermatitis
EXAMPLES=examples
PLINGUA=bin/plingua
PSIM=bin/psim
RLINGUA=bin/rlingua

for SEV in mild moderate severe; do
    echo "=== AD $SEV ==="

    # Phase 1: barrier permeability
    $PLINGUA $EXAMPLES/skin/conditions/$COND/ad_barrier_${SEV}.pli \
        -I $EXAMPLES -o /tmp/ad_barrier_${SEV}.psim
    $PSIM /tmp/ad_barrier_${SEV}.psim -steps 200 -v \
        -o /tmp/ad_barrier_${SEV}_sim.json

    # Phase 3: biology
    bin/mlingua $EXAMPLES/skin/conditions/$COND/ad_biology_${SEV}.mli \
        -o /tmp/ad_bio_${SEV}.msim
    bin/msim /tmp/ad_bio_${SEV}.msim -steps 400 -v

done

# Phase 5: R-Lingua grip (condition-level, severity-independent)
$RLINGUA $EXAMPLES/skin/conditions/$COND/ad_rr.rli -s 300 -v \
    -o /tmp/ad_grip_report.json
```

### 3.2 Acne — All Severities

```bash
COND=acne
for SEV in mild moderate severe; do
    echo "=== Acne $SEV ==="
    bin/mlingua $EXAMPLES/skin/conditions/$COND/acne_sebaceous_${SEV}.mli \
        -o /tmp/acne_seb_${SEV}.msim
    bin/msim /tmp/acne_seb_${SEV}.msim -steps 400 -v
done
bin/rlingua $EXAMPLES/skin/conditions/$COND/acne_rr.rli -s 300 -v \
    -o /tmp/acne_grip_report.json
```

### 3.3 Psoriasis — All Severities

```bash
COND=psoriasis
for SEV in mild moderate severe; do
    echo "=== PSO $SEV ==="
    $PLINGUA $EXAMPLES/skin/conditions/$COND/pso_barrier_${SEV}.pli \
        -I $EXAMPLES -o /tmp/pso_barrier_${SEV}.psim
    $PSIM /tmp/pso_barrier_${SEV}.psim -steps 200 -v

    bin/mlingua $EXAMPLES/skin/conditions/$COND/pso_biology_${SEV}.mli \
        -o /tmp/pso_bio_${SEV}.msim
    bin/msim /tmp/pso_bio_${SEV}.msim -steps 400 -v
done
bin/rlingua $EXAMPLES/skin/conditions/$COND/pso_rr.rli -s 300 -v \
    -o /tmp/pso_grip_report.json
```

### 3.4 Rosacea — All Severities

```bash
COND=rosacea
for SEV in mild moderate severe; do
    bin/mlingua $EXAMPLES/skin/conditions/$COND/rosa_inflammatory_${SEV}.mli \
        -o /tmp/rosa_${SEV}.msim
    bin/msim /tmp/rosa_${SEV}.msim -steps 400 -v
done
bin/rlingua $EXAMPLES/skin/conditions/$COND/rosa_rr.rli -s 300 -v \
    -o /tmp/rosa_grip_report.json
```

### 3.5 Hyperpigmentation — All Severities

```bash
COND=hyperpigmentation
for SEV in mild moderate severe; do
    bin/mlingua $EXAMPLES/skin/conditions/$COND/hyper_melanogenesis_${SEV}.mli \
        -o /tmp/hyper_${SEV}.msim
    bin/msim /tmp/hyper_${SEV}.msim -steps 400 -v
done
bin/rlingua $EXAMPLES/skin/conditions/$COND/hyper_rr.rli -s 300 -v \
    -o /tmp/hyper_grip_report.json
```

### 3.6 Photoaging — All Severities

```bash
COND=photoaging
for SEV in mild moderate severe; do
    bin/mlingua $EXAMPLES/skin/conditions/$COND/photo_mmp_${SEV}.mli \
        -o /tmp/photo_${SEV}.msim
    bin/msim /tmp/photo_${SEV}.msim -steps 400 -v
done
bin/rlingua $EXAMPLES/skin/conditions/$COND/photo_rr.rli -s 300 -v \
    -o /tmp/photo_grip_report.json
```

---

## 4. Full Condition × Severity × Formulation Sweep

Run the complete matrix with the following script (requires all binaries built):

```bash
#!/usr/bin/env bash
# full_matrix_sweep.sh — complete condition × severity × formulation experiment
set -euo pipefail

PLINGUA=bin/plingua
PSIM=bin/psim
RLINGUA=bin/rlingua
MLINGUA=bin/mlingua
MSIM=bin/msim
EXAMPLES=examples
OUT=/tmp/skin_matrix

mkdir -p "$OUT"

CONDS=(atopic_dermatitis acne psoriasis rosacea hyperpigmentation photoaging)
SEVS=(mild moderate severe)

for COND in "${CONDS[@]}"; do
    echo "===== $COND ====="

    # Compile R-Lingua grip model
    if [ -f "$EXAMPLES/skin/conditions/$COND/${COND}_rr.rli" ]; then
        NAME=$(echo "$COND" | sed 's/atopic_dermatitis/ad/;s/hyperpigmentation/hyper/;s/photoaging/photo/;s/psoriasis/pso/;s/rosacea/rosa/;s/acne/acne/')
        $RLINGUA "$EXAMPLES/skin/conditions/$COND/${NAME}_rr.rli" -s 300 \
            -o "$OUT/${COND}_grip.json"
        echo "  grip: $OUT/${COND}_grip.json"
    fi

    for SEV in "${SEVS[@]}"; do
        echo "  severity: $SEV"

        # Phase 1 (.pli) — AD and PSO
        for PLI in "$EXAMPLES/skin/conditions/$COND"/*_barrier_${SEV}.pli 2>/dev/null; do
            [ -f "$PLI" ] || continue
            BASE=$(basename "$PLI" .pli)
            $PLINGUA "$PLI" -I "$EXAMPLES" -o "$OUT/${BASE}.psim"
            $PSIM "$OUT/${BASE}.psim" -steps 200 -o "$OUT/${BASE}_sim.json"
            echo "    phase1 sim: $OUT/${BASE}_sim.json"
        done

        # Phase 3/4 (.mli) — all conditions
        for MLI in "$EXAMPLES/skin/conditions/$COND"/*_${SEV}.mli 2>/dev/null; do
            [ -f "$MLI" ] || continue
            BASE=$(basename "$MLI" .mli)
            $MLINGUA "$MLI" -o "$OUT/${BASE}.msim"
            $MSIM "$OUT/${BASE}.msim" -steps 400 -o "$OUT/${BASE}_sim.json"
            echo "    tissue sim: $OUT/${BASE}_sim.json"
        done
    done
done

echo ""
echo "All matrix runs complete. Results in: $OUT/"
```

---

## 5. Acceptance Criteria Summary

| Condition | Key metric | Direction vs healthy | Threshold |
|-----------|-----------|---------------------|-----------|
| AD mild | X_clr count (barrier flux) | ↑ ≥ 20% | ✓ if clr_ad_mild > 24 |
| AD moderate | nfkb_active at step 100 | > 0 | ✓ if nfkb > 0 |
| AD severe | repair_signal | = 0 | ✓ if no repair |
| AD any | grip_index NIA↔VE | ≥ 0.60 | per ad_rr.rli |
| Acne mild | sebum tokens | ↑ ≥ 2× | sebum > 20 |
| Acne any | grip_index CBD↔SC | ≥ 0.70 | per acne_rr.rli |
| PSO mild | il17 tokens | > 0 | present |
| PSO any | grip_index retinol↔VE | ≥ 0.60 | per pso_rr.rli |
| Rosacea mild | histamine tokens | > 0 | present |
| Rosacea any | grip_index CBD↔dermis | ≥ 0.50 | per rosa_rr.rli |
| HYP mild | melanosome tokens | ↑ ≥ 2× | mel > healthy |
| HYP any | grip_index NIA↔VE | ≥ 0.70 | per hyper_rr.rli |
| PAG mild | mmp1 tokens | ↑ ≥ 2× | mmp1 > 10 |
| PAG any | grip_index retinol↔dermis | ≥ 0.55 | per photo_rr.rli |
| Baseline (healthy) | All metrics | Unchanged | Regression test |

---

## 6. Baseline Regression Check

Before any condition model run, verify the healthy baseline has not changed:

```bash
# Healthy SC/VE diffusion
bin/plingua examples/skin/sc_ve_diffusion.pli -I examples -o /tmp/healthy.psim
bin/psim /tmp/healthy.psim -steps 200 -o /tmp/healthy_sim.json

# Healthy barrier biology
bin/mlingua examples/skin/barrier_repair.mli -o /tmp/healthy_bio.msim
bin/msim /tmp/healthy_bio.msim -steps 400

# Healthy R-Lingua baseline
bin/rlingua examples/skin/skin_rr.rli -s 300 -o /tmp/healthy_grip.json
```

Confirm `healthy_sim.json` outputs are within ±5% of reference run before
comparing condition variant outputs.
