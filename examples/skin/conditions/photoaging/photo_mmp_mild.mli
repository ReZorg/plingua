/*
 * photo_mmp_mild.mli — Photoaging Phase 4: Mild MMP/ECM Imbalance
 *
 * Variant of retinol.mli + niacinamide.mli for mild photoaging.
 * Key perturbations from healthy baseline:
 *
 *   • mmp1 initial: 10 (healthy=5) — mild UV-induced MMP-1 (collagenase) elevation
 *   • mmp3 initial: 7 (healthy=3) — mild MMP-3 (stromelysin) elevation
 *   • ros initial: 3 (healthy=0) — mild oxidative stress from cumulative UV
 *   • methylglyoxal: 8 (healthy=5) — mild advanced glycation (AGE accumulation)
 *   • Retinol load: 30 (unchanged) — rescue dose evaluated
 *
 * Severity tier: MILD (fine lines, early photoaging, Glogau I–II)
 *
 * Biological basis
 * ────────────────
 * Cumulative UV → AP-1 (c-Fos/c-Jun) → MMP-1/MMP-3 induction →
 * procollagen-I peptide cleavage → net collagen loss.
 * UV → ROS → mitochondrial damage → NAD⁺ depletion → SIRT1 impairment →
 * NF-κB derepression → further MMP induction.
 * Retinol → RA → RAR → AP-1 inhibition / RECK induction → MMP inhibition.
 * Niacinamide → NAD⁺ → SIRT1 → NF-κB derepression blocked.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/photoaging/photo_mmp_mild.mli \
 *       -o /tmp/photo_mild.msim
 *   bin/msim /tmp/photo_mild.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_rar;
    @glue glue_crab;
    @glue glue_fib;
    @glue glue_mmp;
    @glue glue_nuc;
    @glue glue_air;
    @glue glue_ker;

    @glue_relation(glue_rar,  glue_rar);
    @glue_relation(glue_crab, glue_crab);
    @glue_relation(glue_fib,  glue_fib);
    @glue_relation(glue_mmp,  glue_mmp);
    @glue_relation(glue_nuc,  glue_nuc);
    @glue_relation(glue_ker,  glue_ker);

    @glue_radius 0.12;

    /* Keratinocyte — RAR target for retinol rescue */
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

    /* Dermal fibroblast — MMP production site */
    @tile fibroblast(sides=4, radius=15) {
        @connector c1(vertices=[v1,v2], glue=glue_fib, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_fib, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_fib, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_fib, angle=90);
        @connector c_mmp(vertices=[center], glue=glue_mmp, angle=90);
        @connector c_rar(vertices=[center], glue=glue_rar, angle=-90);
        @surface_glue glue_fib;
        @color Wheat alpha=180;
        @protion p_col1  at ( 0,  4);   /* collagen-I synthesis */
        @protion p_mmp1  at ( 4,  0);   /* MMP-1 (collagenase) */
        @protion p_mmp3  at (-4,  0);   /* MMP-3 (stromelysin) */
        @protion p_reck  at ( 0, -4);   /* RECK: MMP inhibitor (retinol target) */
    }

    @seed retinol_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — mild photoaging ──────────────────────────────────── */

/* Retinol (rescue agent — same dose as healthy baseline) */
@floating retinol(mobility=2.5, radius=0.09, concentration=30);
@floating retinaldehyde(mobility=3.0, radius=0.08, concentration=0);
@floating retinoic_acid(mobility=3.5, radius=0.07, concentration=0);
@floating crabp_complex(mobility=2.0, radius=0.12, concentration=0);
@floating irritation_signal(mobility=6.0, radius=0.04, concentration=0);

/* Collagen synthesis/degradation */
@floating collagen_pre(mobility=0.8, radius=0.20, concentration=0);
@floating collagen_i(mobility=0.5, radius=0.30, concentration=0);
@floating collagen_iii(mobility=0.5, radius=0.30, concentration=0);

/* MMPs — mildly elevated in mild photoaging */
@floating mmp1(mobility=3.5, radius=0.07, concentration=10);           /* healthy=5, mild=10 */
@floating mmp3(mobility=3.5, radius=0.07, concentration=7);            /* healthy=3, mild=7 */

/* Oxidative stress (mild UV-induced ROS) */
@floating ros(mobility=8.0, radius=0.03, concentration=3);             /* healthy=0, mild=3 */

/* Glycation products */
@floating methylglyoxal(mobility=6.0, radius=0.03, concentration=8);   /* healthy=5, mild=8 */

/* Niacinamide (co-administered for NAD⁺ rescue) */
@floating niacinamide(mobility=5.5, radius=0.04, concentration=30);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);

/* Inflammation proxy */
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);
@floating il1b(mobility=7, radius=0.04, concentration=0);

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
@sigma(glue_mmp, glue_mmp) = mmp1, mmp3;
@sigma(glue_nuc, glue_nuc) = nad_plus;

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Retinol metabolic activation */
    p_raldh: retinol       --> retinaldehyde;
    p_rar:   retinaldehyde --> retinoic_acid;
    p_rar:   retinoic_acid, irritation_signal --> crabp_complex;

    /* RAR → RECK expression (AP-1 antagonism / MMP inhibition) */
    p_rar:   retinoic_acid, mmp1 --> mmp1_blk;
    p_rar:   retinoic_acid, mmp3 --> mmp3_blk;
    p_reck:  retinoic_acid       --> reck_signal;

    /* Retinol → collagen-I pre-collagen synthesis */
    p_col1: retinoic_acid, collagen_pre --> collagen_i;
    p_col1: retinoic_acid               --> collagen_pre;
    collagen_pre, collagen_pre          --> collagen_iii;

    /* MMP-1 collagenase (mild elevation: cleaves collagen slower) */
    p_mmp1: mmp1, collagen_i   --> mmp1;    /* collagen degradation */
    p_mmp3: mmp3, collagen_iii --> mmp3;

    /* ROS → NF-κB → MMP amplification (mild photoaging) */
    ros, ros --> nfkb_active;       /* ROS triggers NF-κB */
    p_nfkb: nfkb_active --> il1b, nfkb_active;
    nfkb_active --> mmp1, mmp3, nfkb_active;   /* NF-κB → MMP induction */

    /* Niacinamide → NAD⁺ → SIRT1 → NF-κB derepression blocked */
    niacinamide --> nmn;
    nmn --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;

    /* Anti-glycation (niacinamide traps methylglyoxal) */
    niacinamide, methylglyoxal --> niacinamide_mgly;

    /* ROS quenching (partial — mild) */
    nad_plus, ros --> nad_plus;

    @create retinoic_acid, retinoic_acid, retinoic_acid --> retinol_keratinocyte;
    @create collagen_pre, collagen_pre, retinoic_acid   --> fibroblast;
}
