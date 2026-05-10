/*
 * pso_biology_mild.mli — Psoriasis Phase 3: Mild Barrier Biology
 *
 * Variant of barrier_repair.mli for mild psoriasis.
 * Key perturbations:
 *
 *   • Keratinocyte proliferation rate increased (faster @create rules)
 *   • Ceramide substrates mildly reduced (serine=16, palmitoyl_coa=12)
 *   • IL-1β (3), TNF-α (1), NF-κB (1) at t = 0 (low-grade Th17 response)
 *   • Filaggrin proxy token (filaggrin) starts reduced
 *   • KSC elevated (5 tokens)
 *   • Repair signal intact
 *
 * Severity tier: MILD (PASI < 10)
 *
 * Biological basis
 * ────────────────
 * Th17 IL-17A → CXCL8, IL-36γ → keratinocyte differentiation block.
 * Transit time through VE shortened from 28→14 days in mild PSO.
 * Filaggrin expression reduced by IL-17A (same pathway as AD).
 * CerS3/CerS4 partially impaired by IL-17 → SC ceramide reduced.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/psoriasis/pso_biology_mild.mli \
 *       -o /tmp/pso_bio_mild.msim
 *   bin/msim /tmp/pso_bio_mild.msim -steps 500 -v
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

    /* sc_healthy — mild PSO: parakeratotic variants begin appearing */
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
        /* Mild PSO: 5 cell cycle counters (same as healthy) */
        @protion p_cc at ( 4,  4);
        @protion p_cc at ( 4, -4);
        @protion p_cc at (-4,  4);
        @protion p_cc at (-4, -4);
        @protion p_cc at ( 0,  0);
        @protion p_spt at (2, 0);
    }

    /* sc_inflamed — psoriatic parakeratotic tile */
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

/* ── Floating objects — mild PSO ─────────────────────────────────────────── */

@floating serine(mobility=6, radius=0.03, concentration=16);          /* healthy=20, mild PSO=16 */
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=12);   /* healthy=15, mild PSO=12 */
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Mild Th17 cytokine burden */
@floating il1b(mobility=7, radius=0.04, concentration=3);             /* mild PSO Th17 baseline */
@floating tnfa(mobility=7, radius=0.04, concentration=1);
@floating nfkb_active(mobility=5, radius=0.05, concentration=1);

/* il17 as Th17 marker (new object specific to PSO) */
@floating il17(mobility=7, radius=0.04, concentration=2);

/* Differentiation deficit markers (IL-17-driven) */
@floating filaggrin(mobility=2, radius=0.10, concentration=1);        /* healthy > PSO */
@floating loricrin(mobility=2, radius=0.10, concentration=1);         /* cornification impaired */

/* KSC elevated in PSO */
@floating ksc(mobility=4, radius=0.05, concentration=5);              /* healthy=2, mild PSO=5 */
@floating cdsn(mobility=1, radius=0.10, concentration=5);

@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cc;
@protion p_spt;
@protion p_lb;
@protion p_gba;
@protion p_nfkb;

/* ── Sigma ───────────────────────────────────────────────────────────────── */
@sigma(glue_tj, glue_tj) = ceramide, ceramide, ceramide;
@sigma(glue_weak, glue_cer) = il1b, il1b, il17;   /* PSO: IL-17 at inflamed front */

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Ceramide synthesis */
    p_spt: serine, palmitoyl_coa --> sphinganine;
    sphinganine --> dihydroceramide;
    dihydroceramide --> ceramide;
    p_gba: glucosylceramide --> ceramide;

    /* LB (intact in mild PSO) */
    p_lb: ceramide, ceramide, ceramide --> lb_vesicle;
    p_lb: lb_vesicle --> ceramide, ceramide, ceramide;

    /* Desquamation (accelerated by KSC) */
    p_cc: ksc, cdsn --> cdsn_cleaved;
    @destroy dsq_signal, sc_healthy --> serine, serine, repair_signal;
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* NF-κB + IL-17 cascade (mild PSO: both pathways active) */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;
    p_nfkb: il17  --> nfkb_active;       /* IL-17 additional NF-κB input */
    nfkb_active --> il1b, tnfa, nfkb_active;
    nfkb_active --> il17, nfkb_active;   /* NF-κB drives IL-17 production */
    nfkb_active, ceramide --> nfkb_active;

    /* Tile replacement (same threshold as healthy) */
    @create nfkb_active, nfkb_active, sc_healthy --> sc_inflamed;
    @destroy nfkb_active, sc_inflamed --> il1b, il17, tnfa;

    /* Hyperproliferation: @create keratinocyte tile with lower threshold */
    /* In healthy, EGF required; in PSO, NF-κB alone sufficient */
    @create nfkb_active, nfkb_active, nfkb_active --> granular_cell;

    /* Cornification deficit (IL-17 reduces filaggrin/loricrin) */
    il17, filaggrin --> il17;            /* IL-17 consumes filaggrin (differentiation block) */
    il17, loricrin  --> il17;

    /* Barrier repair (intact but slower in mild PSO) */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;
    repair_signal, nfkb_active --> repair_signal;

    @create serine, serine, palmitoyl_coa, palmitoyl_coa --> granular_cell;
    @destroy repair_signal, granular_cell --> serine, serine,
                                              palmitoyl_coa, palmitoyl_coa;
}
