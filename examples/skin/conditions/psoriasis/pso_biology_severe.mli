/*
 * pso_biology_severe.mli — Psoriasis Phase 3: Severe Barrier Biology
 *
 * Variant of barrier_repair.mli for severe psoriasis (PASI > 20).
 * Key perturbations:
 *
 *   • Ceramide substrates near-absent: serine=8, palmitoyl_coa=5
 *   • Heavy cytokine load: IL-1β (12), TNF-α (7), NF-κB (5), IL-17 (8)
 *   • Filaggrin/loricrin absent (complete cornification block)
 *   • KSC maximally elevated (12 tokens)
 *   • LB non-functional (empty sigma)
 *   • NF-κB constitutive with amplified IL-17 positive feedback
 *   • Hyperproliferation maximal (single NF-κB token triggers granular cell)
 *
 * Severity tier: SEVERE (PASI > 20, erythrodermic)
 *
 * Biological basis
 * ────────────────
 * Erythrodermic / pustular psoriasis: complete Th17 dominance, absent SC
 * differentiation, keratinocyte transit time 3–5 days (healthy = 28 days).
 * Biologics (anti-IL-17A/F, anti-IL-23p19) target this cytokine cascade.
 * The sc_healthy tile almost never forms — sc_inflamed dominates entirely.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/psoriasis/pso_biology_severe.mli \
 *       -o /tmp/pso_bio_sev.msim
 *   bin/msim /tmp/pso_bio_sev.msim -steps 500 -v
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

    /* sc_healthy — almost never present in severe PSO */
    @tile sc_healthy(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_cer, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_cer, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_cer, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_cer, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_cer, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_cer, angle=60);
        @connector c_top(vertices=[center], glue=glue_air, angle=90);
        @connector c_base(vertices=[center], glue=glue_tj, angle=-90);
        @surface_glue glue_air;
        @color Wheat alpha=200;
        /* Severe PSO: 2 cell-cycle counters (transit 28→5 days) */
        @protion p_cc at ( 4,  4);
        @protion p_cc at (-4, -4);
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
        @connector c_base(vertices=[center], glue=glue_tj, angle=-90);
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
        @protion p_lb   at ( 3,  3);
        @protion p_lb   at (-3,  3);
        @protion p_lb   at ( 0,  4);
        @protion p_gba  at (0, -2);
        @protion p_nfkb at (-3, -3);
    }

    @seed sc_healthy at (0, 0, 0);
}

/* ── Floating objects — severe PSO ──────────────────────────────────────── */

@floating serine(mobility=6, radius=0.03, concentration=8);            /* severe PSO=8 */
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=5);     /* severe PSO=5 */
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Severe PSO cytokine burden */
@floating il1b(mobility=7, radius=0.04, concentration=12);
@floating tnfa(mobility=7, radius=0.04, concentration=7);
@floating nfkb_active(mobility=5, radius=0.05, concentration=5);
@floating il17(mobility=7, radius=0.04, concentration=8);

/* Cornification markers: absent in severe PSO */
@floating filaggrin(mobility=2, radius=0.10, concentration=0);
@floating loricrin(mobility=2, radius=0.10, concentration=0);

@floating ksc(mobility=4, radius=0.05, concentration=12);              /* severe PSO=12 */
@floating cdsn(mobility=1, radius=0.10, concentration=3);
@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cc;
@protion p_spt;
@protion p_lb;
@protion p_gba;
@protion p_nfkb;

/* ── Sigma: NF-κB released from disrupted tile (no ceramide LB) ─────────── */
@sigma(glue_tj, glue_tj) = nfkb_active, il17;
@sigma(glue_weak, glue_cer) = il1b, il1b, il17, il17, tnfa;

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    p_spt: serine, palmitoyl_coa --> sphinganine;
    sphinganine --> dihydroceramide;
    dihydroceramide --> ceramide;
    p_gba: glucosylceramide --> ceramide;

    /* LB non-functional: converts ceramide → NF-κB signal */
    p_lb: ceramide --> nfkb_active;
    p_lb: lb_vesicle --> nfkb_active;

    /* Desquamation — maximally accelerated */
    p_cc: ksc, cdsn --> cdsn_cleaved;
    @destroy dsq_signal, sc_healthy --> repair_signal;
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* NF-κB + maximal IL-17 amplification */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;
    p_nfkb: il17  --> nfkb_active;
    nfkb_active --> il1b, il1b, tnfa, tnfa, nfkb_active;
    nfkb_active --> il17, il17, il17, nfkb_active;
    nfkb_active, ceramide --> nfkb_active;

    /* Hyperproliferation: single NF-κB triggers tile creation */
    @create nfkb_active, sc_healthy --> sc_inflamed;
    @create nfkb_active, il17 --> granular_cell;
    @destroy nfkb_active, sc_inflamed --> il1b, il17, il17, il17, tnfa;

    /* Cornification completely blocked — filaggrin cannot accumulate */
    il17, filaggrin --> il17;
    il17, loricrin  --> il17;

    /* Barrier repair: barely possible — requires large ceramide bolus */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;
    repair_signal, nfkb_active --> repair_signal;

    @create serine, palmitoyl_coa --> granular_cell;
    @destroy repair_signal, granular_cell --> serine, palmitoyl_coa;
}
