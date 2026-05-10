/*
 * ad_biology_moderate.mli — Atopic Dermatitis Phase 3: Moderate Barrier Biology
 *
 * Variant of barrier_repair.mli for moderate atopic dermatitis.
 * Key perturbations from healthy baseline:
 *
 *   • Ceramide substrates severely reduced: serine 20→9, palmitoyl_coa 15→7
 *   • Pre-existing IL-1β (5), TNF-α (2), NF-κB active (1) at t = 0
 *   • KSC strongly elevated (6 tokens); CDSN reduced (3 tokens)
 *   • Repair signal absent (homeostatic balance impaired)
 *   • @sigma ceramide release from LB reduced to 1 token (near-absent LB content)
 *
 * Severity tier: MODERATE
 *
 * Biological basis
 * ────────────────
 * In moderate AD (EASI 16–40), chronic IL-4/IL-13/IL-31 causes near-complete
 * suppression of CerS3/CerS4 and ELOVL1 (elongase) in SG keratinocytes.
 * The LEKTI (SPINK5) / KSC axis is strongly dysregulated.
 * FLG biallelic mutations in ~40% of moderate AD patients → absent NMF.
 * Repair is delayed (impaired AMP / sphingosine pathway).
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/atopic_dermatitis/ad_biology_moderate.mli \
 *       -o /tmp/ad_bio_mod.msim
 *   bin/msim /tmp/ad_bio_mod.msim -steps 500 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_cer;
    @glue glue_weak;
    @glue glue_tj;
    @glue glue_dsg;
    @glue glue_air;

    @glue_relation(glue_cer,  glue_cer);
    @glue_relation(glue_weak, glue_weak);
    @glue_relation(glue_cer,  glue_weak);
    @glue_relation(glue_tj,   glue_tj);
    @glue_relation(glue_dsg,  glue_dsg);

    @glue_radius 0.10;

    @tile sc_healthy(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_cer, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_cer, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_cer, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_cer, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_cer, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_cer, angle=60);
        @connector c_top(vertices=[center], glue=glue_air, angle=90);
        @connector c_base(vertices=[center], glue=glue_tj,  angle=-90);
        @surface_glue glue_air;
        @color Wheat alpha=200;
        @protion p_cc at ( 4,  4);
        @protion p_cc at ( 4, -4);
        @protion p_cc at (-4,  4);
        @protion p_cc at (-4, -4);
        @protion p_cc at ( 0,  0);
        @protion p_spt at (2, 0);
    }

    @tile sc_inflamed(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_weak, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_weak, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_weak, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_weak, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_weak, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_weak, angle=60);
        @connector c_top(vertices=[center], glue=glue_air, angle=90);
        @connector c_base(vertices=[center], glue=glue_tj,  angle=-90);
        @surface_glue glue_air;
        @color OrangeRed alpha=160;
        @protion p_spt at (0, 0);
    }

    @tile granular_cell(sides=6, radius=9) {
        @connector c1(vertices=[v1,v2], glue=glue_dsg, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_dsg, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_dsg, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_dsg, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_dsg, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_dsg, angle=60);
        @connector c_apical(vertices=[center], glue=glue_tj, angle=90);
        @connector c_basal(vertices=[center], glue=glue_tj, angle=-90);
        @surface_glue glue_dsg;
        @color LightYellow alpha=200;
        @protion p_lb  at ( 3,  3);
        @protion p_lb  at (-3,  3);
        @protion p_lb  at ( 0,  4);
        @protion p_gba at (0, -2);
        @protion p_nfkb at (-3, -3);
    }

    @seed sc_healthy at (0, 0, 0);
}

/* ── Floating objects — moderate AD ─────────────────────────────────────── */

/* Sphingolipid substrates severely reduced in moderate AD */
@floating serine(mobility=6, radius=0.03, concentration=9);          /* healthy=20, mod=9 */
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=7);   /* healthy=15, mod=7 */
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Pre-existing Th2 cytokine burden (moderate AD: EASI 16–40) */
@floating il1b(mobility=7, radius=0.04, concentration=5);            /* healthy=0, mod=5 */
@floating tnfa(mobility=7, radius=0.04, concentration=2);            /* healthy=0, mod=2 */
@floating nfkb_active(mobility=5, radius=0.05, concentration=1);     /* healthy=0, mod=1 */

/* KSC strongly elevated; CDSN substrate reduced */
@floating ksc(mobility=4, radius=0.05, concentration=6);              /* healthy=2, mod=6 */
@floating cdsn(mobility=1, radius=0.10, concentration=3);             /* healthy=5, mod=3 */

/* Repair signal absent (homeostatic balance impaired in moderate AD) */
@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cc;
@protion p_spt;
@protion p_lb;
@protion p_gba;
@protion p_nfkb;

/* ── Sigma: severely reduced LB content ─────────────────────────────────── */
/* Only 1 ceramide released per LB fusion event (healthy=3) */
@sigma(glue_tj, glue_tj) = ceramide;

/* Inflamed front propagates IL-1β (amplified in moderate AD) */
@sigma(glue_weak, glue_cer) = il1b, il1b, il1b;

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Ceramide synthesis — severely substrate-limited */
    p_spt: serine, palmitoyl_coa --> sphinganine;
    sphinganine --> dihydroceramide;
    dihydroceramide --> ceramide;
    p_gba: glucosylceramide --> ceramide;

    /* LB exocytosis (reduced ceramide content — near-empty LBs) */
    p_lb: ceramide, ceramide --> lb_vesicle;         /* requires only 2 (vs 3) — lower threshold */
    p_lb: lb_vesicle --> ceramide, ceramide;

    /* Desquamation (accelerated by elevated KSC) */
    p_cc: ksc, cdsn --> cdsn_cleaved;
    @destroy dsq_signal, sc_healthy --> serine, repair_signal;   /* less serine recycled */
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* NF-κB cascade — constitutive in moderate AD */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;
    nfkb_active --> il1b, tnfa, nfkb_active;
    nfkb_active, ceramide --> nfkb_active;

    /* Inflammatory tile replacement (lower NF-κB threshold in moderate AD) */
    @create nfkb_active, sc_healthy --> sc_inflamed;    /* only 1 NF-κB token needed */
    @destroy nfkb_active, sc_inflamed --> il1b, tnfa;

    /* Barrier repair — impaired (no repair_signal generated initially) */
    /* Repair only possible if external repair_signal supplied */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;
    repair_signal, nfkb_active --> repair_signal;

    /* Granular cell: substrate supply nearly exhausted */
    @create serine, serine, palmitoyl_coa, palmitoyl_coa --> granular_cell;
    @destroy repair_signal, granular_cell --> serine, palmitoyl_coa;
}
