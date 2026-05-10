# SKIN_CONDITIONS_SPEC — Multiscale Skin Condition Modeling Specification

This document defines the **v1 condition profile schema** for six clinically validated
skin conditions modeled as perturbations of the healthy multiscale skin baseline
(see `docs/SKIN_MODEL_SPEC.md`).

---

## 1. Condition Inventory and Scope

| ID  | Condition | Pathophysiology class | Primary DSL phases |
|-----|-----------|----------------------|--------------------|
| AD  | Atopic Dermatitis | Barrier-defect + Th2 inflammatory | Phase 1 (`.pli`), Phase 3 (`.mli`), Phase 5 (`.rli`) |
| ACN | Acne | Sebaceous + Th1/innate inflammatory | Phase 2/4 (`.mli`), Phase 5 (`.rli`) |
| PSO | Psoriasis | Hyperproliferative + Th17 inflammatory | Phase 1 (`.pli`), Phase 3 (`.mli`), Phase 5 (`.rli`) |
| ROS | Rosacea | Neurovascular + innate inflammatory | Phase 4 (`.mli`), Phase 5 (`.rli`) |
| HYP | Hyperpigmentation | Melanogenesis + melanosome transfer | Phase 4 (`.mli`), Phase 5 (`.rli`) |
| PAG | Photoaging | MMP/ECM + oxidative | Phase 4 (`.mli`), Phase 5 (`.rli`) |

### Severity Tiers

All conditions implement three severity levels as **parameterized perturbations** from the
healthy baseline (not new DSL features):

| Tier | Label | Biological meaning | Perturbation magnitude |
|------|-------|--------------------|------------------------|
| 1 | mild | Sub-clinical / early onset | ~20–30% shift from healthy |
| 2 | moderate | Clinically established | ~50–100% shift from healthy |
| 3 | severe | Refractory / advanced disease | ~200–400% shift from healthy |

---

## 2. Condition Profile Schema

Every condition profile specifies perturbations at **each model scale**:

```
ConditionProfile {
    id:          string          /* AD | ACN | PSO | ROS | HYP | PAG */
    severity:    mild | moderate | severe
    scale_phase1 {               /* Phase 1 .pli — permeation kinetics */
        X_d_init:        int     /* initial SC drug loading (proxy for barrier integrity) */
        il_tokens_ve:    int     /* pre-seeded cytokine tokens in VE at t=0 */
        back_diffusion:  present | reduced | absent
        cytokine_rules:  list    /* additional VE inflammatory rules */
    }
    scale_phase3 {               /* Phase 3 .mli — barrier biology */
        serine_conc:     float   /* SPT substrate (reduces ceramide capacity) */
        palmitoyl_conc:  float   /* SPT co-substrate */
        il1b_conc:       float   /* pre-existing IL-1β */
        tnfa_conc:       float   /* pre-existing TNF-α */
        nfkb_conc:       float   /* pre-existing NF-κB activation */
        ksc_conc:        float   /* kallikrein-5 (desquamation enzyme) */
        cdsn_conc:       float   /* corneodesmosin (corneodesmolysis substrate) */
        repair_signal:   float   /* barrier repair signal (0 = impaired) */
    }
    scale_phase4 {               /* Phase 4 .mli — active/condition-specific biology */
        condition_objects: map   /* object → concentration adjustments */
        extra_rules:       list  /* condition-specific reaction rules */
    }
    scale_phase5 {               /* Phase 5 .rli — R-Lingua calibration */
        triad_a: { identity_continuity, skill_readiness, motivational_valence }
        triad_b: { constraint_clarity, affordance_density, feedback_latency }
        triad_c: { coupling_strength, reciprocal_shaping, adaptive_fit }
        coupling_matrix: list    /* agent × arena coupling strengths */
        grip_threshold:  float
    }
}
```

---

## 3. Condition Profiles: Atopic Dermatitis (AD)

### Biology
FLG loss-of-function mutations → impaired filaggrin → ceramide deficiency → elevated
TEWL → type-2 skewed (Th2/Th22) immune response → IL-4, IL-13, IL-31 → further
ceramide downregulation via NF-κB (positive feedback loop).

### Phase 1 Perturbations (sc_ve_diffusion.pli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| X_d initial (SC load) | 20 | 24 | 30 | 40 |
| IL-1β tokens in VE | 0 | 1 | 3 | 6 |
| TNF-α tokens in VE | 0 | 0 | 1 | 3 |
| Back-diffusion | present | present | reduced | absent |
| Cytokine-amplified flux rule | none | +1 copy | +2 copies | +3 copies |

### Phase 3 Perturbations (barrier_repair.mli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| serine | 20 | 14 | 9 | 4 |
| palmitoyl_coa | 15 | 10 | 7 | 3 |
| il1b initial | 0 | 2 | 5 | 10 |
| tnfa initial | 0 | 0 | 2 | 5 |
| nfkb_active initial | 0 | 0 | 1 | 3 |
| ksc initial | 2 | 4 | 6 | 9 |
| cdsn initial | 5 | 5 | 3 | 2 |
| repair_signal initial | 0 | 0 | 0 | 0 (impaired) |

### Phase 5 R-Lingua Profile (ad_rr.rli)
- constraint_clarity low (0.25–0.45) — impaired barrier = high TEWL inverse
- affordance_density high (0.85–0.90) — CB2R/TRPV1 upregulated in AD
- NIA ↔ VE and CBD ↔ VE coupling primary (anti-inflammatory + ceramide)
- AHA contra-indicated in AD (no AHA agent)

### Acceptance Criteria (directional)
- X_clr tokens at steady state > healthy by ≥ 20% (elevated Kp in AD)
- nfkb_active tokens at t=step100 > 0 (persistent inflammation)
- repair_signal absent or minimal in severe tier
- grip_index for NIA ↔ VE ≥ 0.60 (high therapeutic relevance)
- grip_index for CBD ↔ VE ≥ 0.50

---

## 4. Condition Profiles: Acne (ACN)

### Biology
Androgen-driven (DHT → 5-AR) sebocyte lipid hyperproduction → excess sebum →
follicular retention / comedogenesis → C. acnes PAMP signalling via TLR2/4 →
innate IL-1β, IL-8 cascade → adaptive IL-17/Th17 → tissue destruction.

### Phase 4 Perturbations (cbd.mli + follicle_shunt.mli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| androgen initial | 3 | 6 | 10 | 15 |
| sebum initial | 10 | 20 | 35 | 55 |
| il1b initial | 0 | 2 | 5 | 8 |
| tnfa initial | 0 | 0 | 2 | 5 |
| nanoparticle follicular load | 8 | 8 | 12 | 18 |
| p_androgen copies on sebocyte | 1 | 2 | 3 | 4 |

### Phase 5 R-Lingua Profile (acne_rr.rli)
- CBD ↔ SC and CBD ↔ VE coupling highest (PPARγ sebostatic + CB2R anti-inflammatory)
- AHA ↔ SC secondary (comedolytic exfoliation)
- affordance_density in VE elevated (sebocyte targets)

### Acceptance Criteria (directional)
- sebum tokens at t=step100 > healthy by ≥ 2× (sebaceous hyperactivity)
- il1b tokens > 0 at steady state (persistent innate inflammation)
- With CBD active: ppar_signal tokens present → sebum tokens ↓ vs. no-CBD baseline
- grip_index for CBD ↔ SC ≥ 0.70 (sebostatic target)

---

## 5. Condition Profiles: Psoriasis (PSO)

### Biology
Th17-polarised immune response (IL-17A/F, IL-22) → keratinocyte hyperproliferation →
parakeratotic SC → NF-κB persistent → acanthosis → impaired cornification
(filaggrin/loricrin loss) → barrier compromise.

### Phase 1 Perturbations (sc_ve_diffusion.pli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| X_d initial | 20 | 22 | 26 | 32 |
| IL-17 proxy tokens | 0 | 1 | 4 | 8 |
| IL-1β tokens in VE | 0 | 1 | 3 | 6 |
| Hyperproliferation signal | none | low | moderate | high |

### Phase 3 Perturbations (barrier_repair.mli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| serine | 20 | 16 | 12 | 8 |
| palmitoyl_coa | 15 | 12 | 9 | 5 |
| il1b initial | 0 | 3 | 7 | 12 |
| tnfa initial | 0 | 1 | 3 | 7 |
| nfkb_active initial | 0 | 1 | 3 | 5 |
| ksc initial | 2 | 5 | 8 | 12 |
| filaggrin proxy | normal | reduced | very low | absent |

### Phase 5 R-Lingua Profile (pso_rr.rli)
- Retinol ↔ VE coupling primary (differentiation rescue)
- NIA ↔ VE coupling secondary (SIRT1 anti-inflammatory)
- constraint_clarity very low (0.20–0.35) — severely disrupted barrier
- High emergence_sensitivity (treatment response binary: responder/non-responder)

### Acceptance Criteria (directional)
- keratinocyte turnover proxy tokens > 2× healthy
- filaggrin absent in severe tier
- With retinol: rar_active tokens present → cornified_envelope accumulation
- grip_index for retinol ↔ VE ≥ 0.60

---

## 6. Condition Profiles: Rosacea (ROS)

### Biology
Neurovascular dysregulation (TRPV1/TRPA1 hyper-reactivity) → flushing + chronic
inflammation → mast cell degranulation → histamine / IL-8 / MCP-1 → neutrophil
recruitment → innate immune hyper-reactivity → Th1 skew (IFN-γ, IL-17).

### Phase 4 Perturbations (cbd.mli mast_cell module baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| histamine initial | 0 | 5 | 10 | 20 |
| il8 initial | 0 | 3 | 6 | 12 |
| mcp1 initial | 0 | 2 | 5 | 10 |
| trpv1_signal initial | 0 | 2 | 5 | 10 |
| mast cell copies | 1 | 2 | 3 | 4 |
| p_hist activity amplification | none | +1× | +2× | +3× |

### Phase 5 R-Lingua Profile (rosa_rr.rli)
- CBD ↔ VE and CBD ↔ dermis coupling primary (mast cell CB2R + TRPV1 modulation)
- NIA ↔ VE secondary (IL-8/MCP-1 suppression via SIRT1)
- High feedback_latency (rosacea flares can be slow → long clearance half-time)
- emergence_sensitivity = 0.55 (flare dynamics → emergence events model bursts)

### Acceptance Criteria (directional)
- histamine tokens at t=step100 > 0 (persistent mast cell degranulation)
- With CBD: histamine_blk tokens present, histamine tokens < no-CBD baseline
- grip_index for CBD ↔ dermis ≥ 0.50

---

## 7. Condition Profiles: Hyperpigmentation (HYP)

### Biology
UV/hormonal/post-inflammatory stimuli → MSH → MC1R → MITF → tyrosinase
upregulation → eumelanin synthesis → melanosome packaging → PAR-2-mediated
transfer to keratinocytes → epidermal pigmentation.

### Phase 4 Perturbations (niacinamide.mli melanocyte module baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| alpha_msh initial | 3 | 6 | 12 | 18 |
| par2_signal initial | 5 | 8 | 15 | 25 |
| tyrosine initial | 10 | 15 | 22 | 30 |
| melanocyte copies | 1 | 1 | 2 | 3 |
| p_tyr activity | normal | +1× | +2× | +3× |

### Phase 5 R-Lingua Profile (hyper_rr.rli)
- NIA ↔ VE coupling highest (PAR-2 block, primary target)
- affordance_density in VE very high (melanocytes, PAR-2 receptor rich)
- AHA ↔ SC secondary (turnover acceleration)
- CBD not primary (limited melanogenesis effect)

### Acceptance Criteria (directional)
- melanosome tokens at t=step100 > 2× healthy baseline
- With niacinamide: par2_blocked tokens present → melanosome_keratin < no-NIA baseline
- grip_index for NIA ↔ VE ≥ 0.70 (primary target)

---

## 8. Condition Profiles: Photoaging (PAG)

### Biology
Cumulative UV → ROS → MMP-1/MMP-3 induction (AP-1) → collagen-I/III
degradation → structural ECM changes + SIRT1/NAD⁺ impairment → reduced
antioxidant capacity → glycation cross-linking → wrinkle/sagging phenotype.

### Phase 4 Perturbations (retinol.mli + niacinamide.mli baseline)

| Parameter | Healthy | Mild | Moderate | Severe |
|-----------|---------|------|----------|--------|
| mmp1 initial | 5 | 10 | 20 | 35 |
| mmp3 initial | 3 | 7 | 15 | 25 |
| ros initial (new object) | 0 | 3 | 8 | 15 |
| methylglyoxal initial | 5 | 8 | 14 | 22 |
| collagen_i initial | 0 | 0 | 0 | 0 (all degraded) |
| retinol initial | 30 | 30 | 30 | 30 (rescue dose) |

### Phase 5 R-Lingua Profile (photo_rr.rli)
- Retinol ↔ dermis coupling primary (MMP inhibition + collagen)
- NIA ↔ dermis secondary (SIRT1 + anti-glycation)
- affordance_density in dermis very high (fibroblast ECM, collagen targets)
- feedback_latency high (collagen remodelling slow, months)

### Acceptance Criteria (directional)
- mmp1/mmp3 tokens > 2× healthy at t=0 (pre-existing UV damage)
- With retinol: mmp1_blk + mmp3_blk tokens accumulate; collagen_i tokens increase
- With niacinamide: niacinamide_mgly tokens accumulate (glycation trap)
- grip_index for retinol ↔ dermis ≥ 0.55

---

## 9. Multiscale Output Requirements

Every condition run must produce the following outputs (mapped to simulation tokens):

| Output metric | Simulation readout | Experimental equivalent |
|---------------|-------------------|------------------------|
| Barrier integrity proxy | `X_clr` count at VE steady state | Kp or TEWL measurement |
| Inflammatory burden | `nfkb_active` + `il1b` + `tnfa` count | Cytokine ELISA (pg/mL) |
| Sebaceous activity | `sebum` token count | Sebumeter reading |
| Melanin pigmentation | `melanosome_keratin` count | Mexameter / spectrophotometer |
| Collagen balance | `collagen_i` + `collagen_iii` - `mmp1_blk` - `mmp3_blk` | Multiphoton SHG imaging |
| Oxidative burden | `ros` token count | TBARS assay proxy |
| Grip class | `grip_index` trajectory (R-Lingua) | IVIVC / Franz cell score |
| Safety alert | `safety_alert` event count (PBPK) | Systemic Cmax |
| Efficacy signal | `efficacy_confirmed` event count | Therapeutic window |

---

## 10. File Naming Convention

```
examples/skin/conditions/<condition>/<condition_abbrev>_<module>_<severity>.{pli,mli}
examples/skin/conditions/<condition>/<condition_abbrev>_rr.rli
```

| Severity suffix | Meaning |
|-----------------|---------|
| `_mild` | Severity tier 1 |
| `_moderate` | Severity tier 2 |
| `_severe` | Severity tier 3 |

### Run commands template

```bash
# Phase 1: compile and simulate barrier model
bin/plingua examples/skin/conditions/<cond>/<file>.pli -o /tmp/<cond>.psim
bin/psim /tmp/<cond>.psim -steps 200 -v -out /tmp/<cond>_flux.csv

# Phase 3/4: compile tissue model
bin/mlingua examples/skin/conditions/<cond>/<file>.mli -o /tmp/<cond>.msim
bin/msim /tmp/<cond>.msim -steps 400 -v

# Phase 5: run R-Lingua grip optimisation
bin/rlingua examples/skin/conditions/<cond>/<cond>_rr.rli -s 300 -v \
    -o /tmp/<cond>_grip.json
```

---

## 11. References

1. Proksch E et al. (2006). Skin as a route of drug and chemical permeation. *J. Dtsch. Dermatol. Ges.*
2. Elias PM, Feingold KR. (2006). *Skin Barrier*. Taylor & Francis. (atopic dermatitis ceramide defect)
3. Zouboulis CC. (2004). Acne and sebaceous gland function. *Clin. Dermatol.* 22(5):360–366.
4. Nestle FO et al. (2009). Psoriasis. *N. Engl. J. Med.* 361(5):496–509.
5. Steinhoff M et al. (2011). Neurophysiological, neuroimmunological, and neuroendocrine basis of pruritus. *J. Invest. Dermatol.* 126(8):1705–1718. (rosacea/TRPV1)
6. Costin GE, Hearing VJ. (2007). Human skin pigmentation. *FASEB J.* 21(4):976–994.
7. Fisher GJ et al. (2002). Mechanisms of photoaging and chronological skin aging. *Arch. Dermatol.* 138(11):1462–1470.
