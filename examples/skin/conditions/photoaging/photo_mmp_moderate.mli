/*
 * photo_mmp_moderate.mli — Photoaging Phase 4: Moderate MMP/ECM Imbalance
 *
 * Variant for moderate photoaging (Glogau II–III, visible wrinkles).
 * Key perturbations from mild:
 *
 *   • mmp1: 20 (mild=10) — significant UV-induced MMP-1 elevation
 *   • mmp3: 15 (mild=7) — significant MMP-3 stromelysin elevation
 *   • ros: 8 (mild=3) — moderate oxidative burden
 *   • methylglyoxal: 14 (mild=8) — advanced glycation accumulation
 *   • nfkb_active: 2 (mild=0) — NF-κB constitutive (low-grade chronic inflam)
 *   • 2× p_mmp1, 2× p_mmp3 protions on fibroblast (elevated MMP production)
 *   • Collagen-I initially absent (accumulated degradation)
 *
 * Severity tier: MODERATE (Glogau II–III: wrinkles at rest)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/photoaging/photo_mmp_moderate.mli \
 *       -o /tmp/photo_mod.msim
 *   bin/msim /tmp/photo_mod.msim -steps 400 -v
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

    /* Fibroblast — moderate: 2× p_mmp1, 2× p_mmp3 (elevated MMP production) */
    @tile fibroblast(sides=4, radius=15) {
        @connector c1(vertices=[v1,v2], glue=glue_fib, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_fib, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_fib, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_fib, angle=90);
        @connector c_mmp(vertices=[center], glue=glue_mmp, angle=90);
        @connector c_rar(vertices=[center], glue=glue_rar, angle=-90);
        @surface_glue glue_fib;
        @color Tan alpha=200;
        @protion p_col1  at ( 0,  5);
        @protion p_mmp1  at ( 5,  0);
        @protion p_mmp1  at ( 5, -3);   /* 2nd p_mmp1: elevated MMP-1 production */
        @protion p_mmp3  at (-5,  0);
        @protion p_mmp3  at (-5, -3);   /* 2nd p_mmp3: elevated MMP-3 production */
        @protion p_reck  at ( 0, -5);
    }

    @seed retinol_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — moderate photoaging ──────────────────────────────── */

@floating retinol(mobility=2.5, radius=0.09, concentration=30);
@floating retinaldehyde(mobility=3.0, radius=0.08, concentration=0);
@floating retinoic_acid(mobility=3.5, radius=0.07, concentration=0);
@floating crabp_complex(mobility=2.0, radius=0.12, concentration=0);
@floating irritation_signal(mobility=6.0, radius=0.04, concentration=0);

@floating collagen_pre(mobility=0.8, radius=0.20, concentration=0);
@floating collagen_i(mobility=0.5, radius=0.30, concentration=0);   /* depleted: start at 0 */
@floating collagen_iii(mobility=0.5, radius=0.30, concentration=0);

/* MMPs — moderate photoaging */
@floating mmp1(mobility=3.5, radius=0.07, concentration=20);          /* moderate=20 */
@floating mmp3(mobility=3.5, radius=0.07, concentration=15);          /* moderate=15 */

/* ROS — moderate */
@floating ros(mobility=8.0, radius=0.03, concentration=8);            /* moderate=8 */

/* Advanced glycation */
@floating methylglyoxal(mobility=6.0, radius=0.03, concentration=14); /* moderate=14 */

@floating niacinamide(mobility=5.5, radius=0.04, concentration=30);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);

/* NF-κB constitutive low level */
@floating nfkb_active(mobility=5, radius=0.05, concentration=2);
@floating il1b(mobility=7, radius=0.04, concentration=1);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_rar;
@protion p_raldh;
@protion p_sirt1;
@protion p_nfkb;
@protion p_col1;
@protion p_mmp1;
@protion p_mmp3;
@protion p_reck;

/* ── Sigma ───────────────────────────────────────────────────────────────── */
@sigma(glue_rar, glue_rar) = retinoic_acid, crabp_complex;
@sigma(glue_mmp, glue_mmp) = mmp1, mmp1, mmp3, mmp3;   /* 2× MMP burst */
@sigma(glue_nuc, glue_nuc) = nad_plus;

@reaction_distance 14;

def main() {

    /* Retinol metabolic activation */
    p_raldh: retinol       --> retinaldehyde;
    p_rar:   retinaldehyde --> retinoic_acid;
    p_rar:   retinoic_acid, irritation_signal --> crabp_complex;

    /* RAR → MMP inhibition */
    p_rar:   retinoic_acid, mmp1 --> mmp1_blk;
    p_rar:   retinoic_acid, mmp3 --> mmp3_blk;
    p_reck:  retinoic_acid       --> reck_signal;

    /* Retinol → collagen synthesis (rescues depleted ECM) */
    p_col1: retinoic_acid, collagen_pre --> collagen_i;
    p_col1: retinoic_acid               --> collagen_pre;
    collagen_pre, collagen_pre          --> collagen_iii;

    /* MMP-1/MMP-3 constitutive collagen degradation (2× rate) */
    p_mmp1: mmp1, collagen_i   --> mmp1;
    p_mmp3: mmp3, collagen_iii --> mmp3;
    /* Additional degradation (2nd protion active) */
    p_mmp1: mmp1, collagen_pre --> mmp1;
    p_mmp3: mmp3, collagen_pre --> mmp3;

    /* ROS → constitutive NF-κB → MMP amplification */
    ros --> nfkb_active;       /* faster ROS conversion in moderate */
    p_nfkb: nfkb_active --> il1b, nfkb_active;
    nfkb_active --> mmp1, mmp3, mmp1, nfkb_active;   /* amplified MMP induction */

    /* Niacinamide → NAD⁺ → SIRT1 → NF-κB suppression */
    niacinamide --> nmn;
    nmn --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;

    /* Anti-glycation */
    niacinamide, methylglyoxal --> niacinamide_mgly;

    /* ROS quenching */
    nad_plus, ros --> nad_plus;

    @create retinoic_acid, retinoic_acid, retinoic_acid --> retinol_keratinocyte;
    @create collagen_pre, retinoic_acid                 --> fibroblast;
}
