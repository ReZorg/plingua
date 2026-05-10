/*
 * photo_mmp_severe.mli — Photoaging Phase 4: Severe MMP/ECM Imbalance
 *
 * Variant for severe photoaging (Glogau IV: deep wrinkles, sagging, actinic).
 * Key perturbations:
 *
 *   • mmp1: 35 — severe, constitutive collagenase activity
 *   • mmp3: 25 — severe stromelysin (degrades multiple ECM components)
 *   • ros: 15 — heavy oxidative burden (actinic damage)
 *   • methylglyoxal: 22 — advanced glycation (collagen cross-linking)
 *   • nfkb_active: 5 — constitutive NF-κB (chronic low-grade inflammation)
 *   • 3× p_mmp1, 3× p_mmp3 protions on fibroblast
 *   • Collagen-I/III absent at t=0 (completely degraded ECM)
 *   • MMP self-amplification constitutive rule
 *   • ROS constitutive generation (mtDNA damage proxy)
 *
 * Severity tier: SEVERE (Glogau IV, deep furrows, actinic keratosis risk)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/photoaging/photo_mmp_severe.mli \
 *       -o /tmp/photo_sev.msim
 *   bin/msim /tmp/photo_sev.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_rar;
    @glue glue_crab;
    @glue glue_fib;
    @glue glue_mmp;
    @glue glue_nuc;
    @glue glue_ker;

    @glue_relation(glue_rar,  glue_rar);
    @glue_relation(glue_crab, glue_crab);
    @glue_relation(glue_fib,  glue_fib);
    @glue_relation(glue_mmp,  glue_mmp);
    @glue_relation(glue_nuc,  glue_nuc);
    @glue_relation(glue_ker,  glue_ker);

    @glue_radius 0.12;

    @tile retinol_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_ker,  angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_ker,  angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_ker,  angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_ker,  angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_ker,  angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_ker,  angle=60);
        @connector c_rar(vertices=[center],  glue=glue_rar,  angle=90);
        @connector c_crab(vertices=[center], glue=glue_crab, angle=-90);
        @connector c_nuc(vertices=[center],  glue=glue_nuc,  angle=45);
        @surface_glue glue_ker;
        @color LightGoldenrodYellow alpha=170;
        @protion p_rar   at ( 3,  0);
        @protion p_raldh at (-3,  0);
        @protion p_sirt1 at ( 0,  3);
        @protion p_nfkb  at ( 0, -3);
    }

    /* Fibroblast — severe: 3× p_mmp1 + 3× p_mmp3 (maximum MMP output) */
    @tile fibroblast(sides=4, radius=15) {
        @connector c1(vertices=[v1,v2], glue=glue_fib, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_fib, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_fib, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_fib, angle=90);
        @connector c_mmp(vertices=[center], glue=glue_mmp, angle=90);
        @connector c_rar(vertices=[center], glue=glue_rar, angle=-90);
        @surface_glue glue_fib;
        @color Sienna alpha=220;
        @protion p_col1  at ( 0,  6);
        @protion p_mmp1  at ( 6,  0);
        @protion p_mmp1  at ( 6, -3);
        @protion p_mmp1  at ( 6, -6);   /* 3rd p_mmp1: severe collagenase activity */
        @protion p_mmp3  at (-6,  0);
        @protion p_mmp3  at (-6, -3);
        @protion p_mmp3  at (-6, -6);   /* 3rd p_mmp3: severe stromelysin activity */
        @protion p_reck  at ( 0, -6);
    }

    @seed retinol_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — severe photoaging ────────────────────────────────── */

@floating retinol(mobility=2.5, radius=0.09, concentration=30);
@floating retinaldehyde(mobility=3.0, radius=0.08, concentration=0);
@floating retinoic_acid(mobility=3.5, radius=0.07, concentration=0);
@floating crabp_complex(mobility=2.0, radius=0.12, concentration=0);
@floating irritation_signal(mobility=6.0, radius=0.04, concentration=0);

@floating collagen_pre(mobility=0.8, radius=0.20, concentration=0);
@floating collagen_i(mobility=0.5, radius=0.30, concentration=0);    /* absent: severe depletion */
@floating collagen_iii(mobility=0.5, radius=0.30, concentration=0);

/* MMPs — severe photoaging: maximum activity */
@floating mmp1(mobility=3.5, radius=0.07, concentration=35);          /* severe=35 */
@floating mmp3(mobility=3.5, radius=0.07, concentration=25);          /* severe=25 */

/* ROS — heavy actinic burden */
@floating ros(mobility=8.0, radius=0.03, concentration=15);           /* severe=15 */

/* Advanced glycation: extensive cross-linking */
@floating methylglyoxal(mobility=6.0, radius=0.03, concentration=22); /* severe=22 */

@floating niacinamide(mobility=5.5, radius=0.04, concentration=30);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);

/* Constitutive NF-κB (chronic photoaged fibroblast senescence) */
@floating nfkb_active(mobility=5, radius=0.05, concentration=5);
@floating il1b(mobility=7, radius=0.04, concentration=3);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_rar;
@protion p_raldh;
@protion p_sirt1;
@protion p_nfkb;
@protion p_col1;
@protion p_mmp1;
@protion p_mmp3;
@protion p_reck;

/* ── Sigma: massive MMP burst from senescent fibroblast contacts ─────────── */
@sigma(glue_rar, glue_rar) = retinoic_acid, crabp_complex;
@sigma(glue_mmp, glue_mmp) = mmp1, mmp1, mmp1, mmp3, mmp3, mmp3;   /* 3× burst */
@sigma(glue_nuc, glue_nuc) = nad_plus;

@reaction_distance 14;

def main() {

    /* Retinol metabolic activation */
    p_raldh: retinol       --> retinaldehyde;
    p_rar:   retinaldehyde --> retinoic_acid;
    p_rar:   retinoic_acid, irritation_signal --> crabp_complex;

    /* RAR → MMP inhibition (rescue — therapeutic effect) */
    p_rar:   retinoic_acid, mmp1 --> mmp1_blk;
    p_rar:   retinoic_acid, mmp3 --> mmp3_blk;
    p_reck:  retinoic_acid       --> reck_signal;

    /* Retinol → collagen de novo (ECM rescue from near-zero baseline) */
    p_col1: retinoic_acid, collagen_pre --> collagen_i;
    p_col1: retinoic_acid               --> collagen_pre;
    collagen_pre, collagen_pre          --> collagen_iii;

    /* MMP constitutive collagen degradation (3× protion → 3× rate) */
    p_mmp1: mmp1, collagen_i   --> mmp1;
    p_mmp3: mmp3, collagen_iii --> mmp3;
    p_mmp1: mmp1, collagen_pre --> mmp1;
    p_mmp3: mmp3, collagen_pre --> mmp3;

    /* MMP self-amplification (SASP: senescent fibroblast bystander effect) */
    mmp1 --> mmp1, mmp1;   /* constitutive MMP-1 self-amplification */
    mmp3 --> mmp3, mmp3;

    /* ROS constitutive generation (mtDNA damage proxy) */
    ros --> ros, ros;      /* mitochondrial ROS amplification */
    ros --> nfkb_active;

    /* Constitutive NF-κB → MMP → more NF-κB */
    p_nfkb: nfkb_active --> il1b, nfkb_active;
    nfkb_active --> mmp1, mmp1, mmp3, mmp3, nfkb_active;

    /* Niacinamide rescue: NAD⁺ → SIRT1 → NF-κB suppression */
    niacinamide --> nmn;
    nmn --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;

    /* Anti-glycation */
    niacinamide, methylglyoxal --> niacinamide_mgly;

    /* ROS quenching (requires large NAD⁺ supply to overcome severe ROS) */
    nad_plus, ros --> nad_plus;
    nad_plus, ros --> nad_plus;   /* 2nd copy: more quenching capacity */

    @create retinoic_acid, retinoic_acid, retinoic_acid --> retinol_keratinocyte;
    @create retinoic_acid                               --> fibroblast;
}
