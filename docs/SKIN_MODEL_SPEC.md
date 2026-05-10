# SKIN_MODEL_SPEC — Multiscale Digital Skin Twin Specification

This document specifies the complete seven-phase **Multiscale Cosmeceutical Skin Model** implemented in plingua.  The model is a mechanistic in-silico representation of transdermal drug delivery and skin pharmacology, expressed across all four plingua DSLs.

---

## 1. Overview and Scope

The model covers:

| Scale | Biological Scope | plingua DSL |
|---|---|---|
| Molecular | Lipid-bilayer partition, Fickian diffusion, enzymatic kinetics | P-Lingua (`.pli`) |
| Cellular | Tile-based 3D tissue architecture, appendageal routes | M-Lingua (`.mli`) |
| Tissue | Barrier biology, ceramide synthesis, inflammation | M-Lingua (`.mli`) |
| Organ | PBPK compartments, systemic distribution, hepatic clearance | P-Lingua + OpenCog (`.pli`) |
| Cognitive | Formulation optimisation, parameter calibration | R-Lingua (`.rli`) |

All three clinically validated transdermal routes are represented:

- **Transcellular** — through corneocyte tiles (via `c_trans` connector)
- **Intercellular** — through lipid lamellae (`glue_lam` lateral connectors)
- **Appendageal (follicular shunt)** — `follicle_shunt.mli` infundibulum → bulge chain

---

## 2. Physicochemical Parameters

All cosmeceutical active molecules are represented as **floating objects**.  The three key parameters map as follows:

| Floating object parameter | Physicochemical meaning | Typical range |
|---|---|---|
| `mobility` | Diffusion coefficient proxy (higher = faster) | 0.3 (nanoparticle) – 9 (proton) |
| `radius` | Molecular radius / steric size | 0.02 (H⁺) – 0.50 (NP) |
| `concentration` | Donor compartment loading (dose proxy) | 0 – 100 |

### Reference Molecule Table

| Active | log P | MW (Da) | pKa | `mobility` | `radius` | Phase |
|---|---|---|---|---|---|---|
| Caffeine (ref) | −0.07 | 194 | 10.4 | 4.5 | 0.04 | 1, 2 |
| CBD | 6.3 | 314.5 | 10.6 | 2.0 | 0.09 | 4 |
| Retinol | 5.7 | 286.5 | — | 2.0 | 0.08 | 4 |
| Niacinamide | −0.37 | 122.1 | 3.3 | 5.5 | 0.04 | 4 |
| Glycolic acid | −1.1 | 76.1 | 3.83 | 5.0 (prot.) | 0.03 | 4 |
| Lactic acid | −0.7 | 90.1 | 3.86 | 4.5 (prot.) | 0.03 | 4 |

---

## 3. Phase 1 — Minimum Viable Skin Model

**File:** `examples/skin/sc_ve_diffusion.pli`

**Model topology:**

```
Donor (infinite source)
  │
  │  X_d*20  (initial SC load)
  ▼
┌─ Membrane 1: Stratum Corneum (SC) ─────────────────────┐
│  X_d ⇌ X_aq   (partition equilibration)                │
│  X_d → [X_aq]'2   (SC → VE permeation)                 │
│  X_aq → X_d   (back-diffusion, probabilistic)           │
└────────────────────────────────────────────────────────┘
  │
  ▼
┌─ Membrane 2: Viable Epidermis (VE) ────────────────────┐
│  X_aq → X_clr   (dermal capillary clearance)            │
│  X_aq → M       (enzymatic metabolism, probabilistic)   │
│  X_clr → X_clr, @d   (dissolution / export)            │
└────────────────────────────────────────────────────────┘
```

**Validation target:** Caffeine Franz cell cumulative permeation ≈ 1–3 µg cm⁻² h⁻¹ at steady state (Surber & Davis 2002; Kattou et al. 2019).

**Parameter tuning:** Adjust rule probabilities to match measured Kp and lag time.

---

## 4. Phase 2 — Spatial Layer Geometry

### 4.1 `skin_layers.mli`

**Tile types:**

| Tile | Cell type | `sides` | `radius` (µm) | Glues |
|---|---|---|---|---|
| `sc_corneocyte` | Corneocyte | 6 | 10 | `glue_lam` (lateral), `glue_cc` (transcellular), `glue_sc_ve` (basal) |
| `keratinocyte` | VE keratinocyte | 6 | 8 | `glue_tj` (lateral), `glue_sc_ve` (apical), `glue_ve_d` (basal) |
| `dermal_fibroblast` | Fibroblast | 8 | 12 | `glue_fb` (lateral), `glue_ve_d` (apical) |

**Routes:**
- Intercellular (lateral lipid): `glue_lam` → `glue_lam`
- Transcellular (pore): `c_trans` (glue_cc) → `c_trans` (glue_cc)
- SC→VE junction: `c_base` (glue_sc_ve) → `c_apical` (glue_sc_ve)
- VE→dermis: `c_basal` (glue_ve_d) → `c_apical` (glue_ve_d)

**Sigma mappings:**

| Glue pair | Objects released | Biological meaning |
|---|---|---|
| `glue_sc_ve` × `glue_sc_ve` | `ceramide, ceramide` | Lamellar body exocytosis at SC–VE junction |
| `glue_ve_d` × `glue_ve_d` | `egf` | Paracrine EGF signalling at VE–dermis junction |

### 4.2 `follicle_shunt.mli`

**Channel tiles:** `follicle_infundibulum` → `follicle_isthmus` → `follicle_bulge`

Sebaceous gland tile (`sebaceous_gland`) injects `sebum` at the isthmus via `glue_seb`.

**Key parameters:**
- Infundibulum radius: 40 µm (≈ 4× SC tortuosity path width)
- Isthmus radius: 20 µm
- Nanoparticle `mobility=0.3`, `radius=0.50` → deposits in infundibulum

---

## 5. Phase 3 — Barrier Biology

**File:** `examples/skin/barrier_repair.mli`

### Sphingolipid Synthesis Pathway

```
serine + palmitoyl_coa
    │  p_spt (SPT)
    ▼
sphinganine
    │
    ▼
dihydroceramide
    │  desaturase
    ▼
ceramide ◄──────── glucosylceramide
              p_gba (GBA salvage)
```

### Lamellar Body Exocytosis

`p_lb` protion on `granular_cell`:  
`ceramide × 3 → lb_vesicle` (packaging)  
`lb_vesicle → ceramide × 3` (sigma-release at SC–VE junction)

### Desquamation Counter

Each `sc_healthy` tile carries 5 × `p_cc` protions.  
KSC (kallikrein-5) + CDSN → `cdsn_cleaved` decrements counter.  
When all 5 consumed → `dsq_signal` → `@destroy sc_healthy`.

### NF-κB Inflammatory Cascade

```
il1b / tnfa
    │  p_nfkb
    ▼
nfkb_active
    │
    ├── ─→ il1b, tnfa   (positive feedback)
    ├── ─→ consumes ceramide   (barrier disruption)
    └── @create nfkb_active × 2, sc_healthy → sc_inflamed
```

### Barrier Repair

```
ceramide × 5 + repair_signal → @create sc_healthy
repair_signal + nfkb_active → repair_signal   (NF-κB suppression)
```

---

## 6. Phase 4 — Cosmeceutical Active Modules

### 6.1 CBD (`actives/cbd.mli`)

| Receptor | Protion | Downstream effect |
|---|---|---|
| CB2R | `p_cb2` | `cbd_free → cb2_signal` → NF-κB suppression |
| TRPV1 | `p_trpv1` | `cbd_free → trpv1_signal → ceramide × 2` |
| PPARγ | `p_ppar` | `cbd_free + androgen → ppar_signal` → sebum suppression |
| CB2R (mast) | `p_cb2` (mast_cell) | `cbd_free → cb2_signal → histamine_blk` |

### 6.2 Retinol (`actives/retinol.mli`)

**Metabolic cascade:**
```
retinol → retinaldehyde → retinoic_acid → crabp_complex → RAR active
                                                    │
                    collagen_pre + filaggrin + involucrin + loricrin
```

**MMP inhibition:** `p_mmp: mmp1/mmp3, retinoic_acid → mmp_blk`  
**Irritation threshold:** `RA × 3 → irritation_signal` (retinoid dermatitis model)

### 6.3 Niacinamide (`actives/niacinamide.mli`)

**NAD⁺ pathway:** `niacinamide → NMN → NAD⁺`

**Key effects:**

| Pathway | Rule | Outcome |
|---|---|---|
| SIRT1 anti-inflammatory | `p_sirt1: nad_plus, nfkb_active → nfkb_inact` | Cytokine suppression |
| PAR-2 melanin-transfer block | `p_par2: niacinamide, par2_signal → par2_blocked` | Hyperpigmentation reduction |
| Anti-glycation | `niacinamide + methylglyoxal → niacinamide_mgly` | Collagen crosslink prevention |
| Barrier lipids | `nad_plus → ceramide + cholesterol` | Indirect PPARα effect |

### 6.4 AHA (`actives/aha.mli`)

**pH equilibrium:**  
`hplus + ga_ionised ⇌ ga_protonated`  
(fraction protonated at pH 3.5 ≈ 25% for GA, pKa 3.83)

**Corneodesmolysis cascade:**
```
ga_protonated + ksc → ksc_active
ksc_active + cdsn → cdsn_cleaved
ksc_active + dsg1 → dsg1_cleaved
cdsn_cleaved × 3 + dsg1_cleaved × 2 + ga_protonated → @create sc_acid_softened
ksc_active + sc_acid_softened → @destroy → ceramide + tgfb
ceramide × 3 + tgfb → @create fresh_corneocyte
```

---

## 7. Phase 5 — R-Lingua Calibration (`skin_rr.rli`)

### Agents (formulations)

| Agent ID | Label | Salience | Affordance |
|---|---|---|---|
| `f_cbd_oil` | CBD oil 1% | 0.80 | 1.6 |
| `f_nia_aq` | Niacinamide gel 5% | 0.75 | 1.4 |
| `f_ret_lipo` | Retinol liposome 0.3% | 0.70 | 1.2 |

### Arenas (skin layers)

| Arena ID | Label | Salience | Affordance |
|---|---|---|---|
| `a_sc` | Stratum Corneum | 0.90 | 0.9 |
| `a_ve` | Viable Epidermis | 0.75 | 1.5 |
| `a_dermis` | Dermis | 0.65 | 1.8 |

### Coupling strengths (permeability proxies)

| Agent | Arena | Coupling type | Strength |
|---|---|---|---|
| `f_cbd_oil` | `a_sc` | co_constitution | 0.85 |
| `f_cbd_oil` | `a_ve` | application | 0.55 |
| `f_cbd_oil` | `a_dermis` | application | 0.20 |
| `f_nia_aq` | `a_sc` | application | 0.30 |
| `f_nia_aq` | `a_ve` | co_constitution | 0.90 |
| `f_nia_aq` | `a_dermis` | application | 0.65 |
| `f_ret_lipo` | `a_sc` | co_constitution | 0.75 |
| `f_ret_lipo` | `a_ve` | co_constitution | 0.70 |
| `f_ret_lipo` | `a_dermis` | application | 0.15 |

### Ennead interpretation

| Ennead dimension | Skin biology meaning |
|---|---|
| `identity_continuity` | Formulation shelf-life / stability |
| `skill_readiness` | Bioavailability readiness |
| `motivational_valence` | Therapeutic potency |
| `constraint_clarity` | Barrier integrity index (inverse TEWL) |
| `affordance_density` | Receptor / binding-site density |
| `feedback_latency` | Clearance half-time |
| `coupling_strength` | Permeability coefficient Kp |
| `reciprocal_shaping` | Formulation–barrier co-adaptation |
| `adaptive_fit` | Target selectivity |

### Grip index interpretation

- `grip_index ≥ 0.6` → optimal formulation–layer pairing
- `grip_index 0.3–0.6` → moderate, may benefit from formulation adjustment
- `grip_index < 0.3` → poor penetration / poor receptor engagement

---

## 8. Phase 6 — PBPK Systemic Coupling (`opencog/skin_pbpk.pli`)

### Compartment topology

```
Membrane 1  Donor
Membrane 2  SC             X_sc ⇌ X_ve (Fickian)
Membrane 3  VE             X_ve → X_dermis; X_ve → M_ve (metabolism)
Membrane 4  Dermis         X_dermis → X_blood (capillary uptake)
Membrane 5  Systemic       X_blood → X_liver + X_clr + X_tissue
Membrane 6  Liver          X_liver → M_liver → M_conj → M_bile
Membrane 7  PLN engine     DermalFlux ∧ BloodClearance → SystemicExposure
Membrane 8  ECAN spreader  flux_high → rr_salience_high (attention to bottleneck)
Membrane 9  OpenPsi drives competence / integrity / exploration
```

### PLN inference rules

| Rule | Condition | Conclusion |
|---|---|---|
| 1 | `flux_high + tv_strong` | `efficacy_signal` |
| 2 | `X_blood × 3 + tv_strong` | `safety_alert` (Cmax > threshold) |
| 3 | `efficacy_signal + conf_high` | `efficacy_confirmed` |

### OpenPsi drives

| Drive | Trigger | Action |
|---|---|---|
| `drive_comp` (competence) | `efficacy_signal` | Increase X_sc dose |
| `drive_integ` (integrity) | `safety_alert` | Reduce X_sc dose |
| `drive_expl` (exploration) | Periodic | Perturb X_sc, X_ve |

---

## 9. Phase 7 — Validation & In-Silico Trial Harness

### Parameter sweep commands

```bash
# SC/VE flux sweep (caffeine validation)
for conc in 10 20 50 100; do
  bin/plingua examples/skin/sc_ve_diffusion.pli \
      -param X_d_init=$conc \
      -o /tmp/sc_ve_$conc.psim
  bin/psim /tmp/sc_ve_$conc.psim -steps 200 \
      -out /tmp/flux_$conc.csv
done

# Formulation comparison (R-Lingua grip report)
bin/rlingua examples/skin/skin_rr.rli -s 300 -v \
    -o /tmp/skin_grip_report.json

# Full PBPK run
bin/plingua examples/opencog/skin_pbpk.pli \
    -o /tmp/skin_pbpk.psim
bin/psim /tmp/skin_pbpk.psim -steps 500 -v \
    -out /tmp/pbpk_timecourse.csv
```

### Output mapping to experimental assays

| Simulation output | Experimental equivalent |
|---|---|
| `X_clr` token count in VE membrane | Franz cell cumulative permeation (µg cm⁻²) |
| Depth profile of `X_sc / X_ve / X_dermis` | Tape-strip HPLC concentration–depth profile |
| `grip_index` trajectory (R-Lingua) | In vitro–in vivo correlation (IVIVC) score |
| `safety_alert` events | Systemic Cmax safety flag |
| `efficacy_confirmed` events | Therapeutic window attainment |
| `flux_high` ECAN attention | Rate-limiting barrier identification |

### Bayesian uncertainty

Encode prior distributions on rate constants by running N independent `psim` replicates with perturbed initial multiset sizes.  Use the distribution of `X_clr` token counts at steady state to estimate posterior flux uncertainty.

```bash
for seed in $(seq 1 50); do
  bin/psim /tmp/sc_ve.psim -steps 200 -seed $seed \
      -out /tmp/replicate_$seed.csv
done
```

---

## 10. References

1. Kattou P, Lian G, Glavin S, Sorrell I, Chen T. (2019). Development of a two-dimensional mathematical model for predicting percutaneous permeation with the follicular pathway. *Pharm. Res.* 36(6):91.
2. Notman R, Anwar J. (2013). Breaching the skin barrier — insights from molecular simulation of model membranes. *Adv. Drug Deliv. Rev.* 65(2):237–250.
3. Elias PM. (2012). Skin barrier function. *Curr. Allergy Asthma Rep.* 8(4):299–305.
4. Surber C, Davis AF. (2002). Bioavailability and bioequivalence of dermatological formulations. *Drugs and the Pharmaceutical Sciences* 119:401–498.
5. Baswan SM et al. (2020). Therapeutic potential of cannabidiol (CBD) for skin health. *Clin. Cosmet. Investig. Dermatol.* 13:927–942.
6. Zasada M, Budzisz E. (2019). Retinoids: active molecules influencing skin structure formation in cosmetic and dermatological treatments. *Postepy Dermatol. Alergol.* 36(4):392–397.
7. Boo YC. (2021). Mechanistic basis and clinical evidence for the applications of nicotinamide (niacinamide) to control skin aging and pigmentation. *Antioxidants* 10(8):1315.
8. Van Scott EJ, Yu RJ. (1984). Hyperkeratinization, corneocyte cohesion, and alpha hydroxy acids. *J. Am. Acad. Dermatol.* 11(5):867–879.
9. Otberg N et al. (2004). Variations of hair follicle size and distribution in different body sites. *J. Invest. Dermatol.* 122(1):14–19.
10. Gilmore BF et al. (2009). Dermal PBPK modelling. *Pharm. Res.* (various).


---

## 11. Skin Condition Models

Six clinically validated skin conditions are modeled as parameterized perturbations
of the healthy baseline described in sections 1–10.  Each condition produces
directionally validated outputs at all model scales.

For the full condition profile schema, severity tier definitions, per-condition
biological rationale, acceptance criteria, and run commands, see:

**`docs/SKIN_CONDITIONS_SPEC.md`**

### Condition inventory

| ID  | Condition | Primary phases | Model directory |
|-----|-----------|---------------|-----------------|
| AD  | Atopic Dermatitis | Phase 1 + 3 + 5 | `examples/skin/conditions/atopic_dermatitis/` |
| ACN | Acne | Phase 4 + 5 | `examples/skin/conditions/acne/` |
| PSO | Psoriasis | Phase 1 + 3 + 5 | `examples/skin/conditions/psoriasis/` |
| ROS | Rosacea | Phase 4 + 5 | `examples/skin/conditions/rosacea/` |
| HYP | Hyperpigmentation | Phase 4 + 5 | `examples/skin/conditions/hyperpigmentation/` |
| PAG | Photoaging | Phase 4 + 5 | `examples/skin/conditions/photoaging/` |

Each condition directory contains mild / moderate / severe severity variants and a
condition-specific R-Lingua file (`*_rr.rli`) for grip index optimisation.

### Multiscale coupling matrix

The condition × severity × formulation experiment matrix with shell runbook is at:

**`examples/skin/conditions/EXPERIMENT_MATRIX.md`**

### Acceptance criteria summary

| Condition | Phase 1 key metric | Phase 3/4 key metric | Phase 5 key metric |
|-----------|-------------------|---------------------|-------------------|
| AD mild | X_clr ↑ ≥ 20% | nfkb_active > 0 | NIA↔VE grip ≥ 0.60 |
| Acne mild | — | sebum ↑ ≥ 2× | CBD↔SC grip ≥ 0.70 |
| PSO mild | il17 present | filaggrin ↓ | retinol↔VE grip ≥ 0.60 |
| Rosacea mild | — | histamine > 0 | CBD↔dermis grip ≥ 0.50 |
| HYP mild | — | melanosome ↑ ≥ 2× | NIA↔VE grip ≥ 0.70 |
| PAG mild | — | mmp1 ↑ ≥ 2× | retinol↔dermis grip ≥ 0.55 |

All condition variants must leave the healthy baseline (sections 1–10) **unchanged**.
