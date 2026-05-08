/*
 * barrier_repair.mli — Phase 3: Dynamic Barrier Biology
 *
 * Models the living SC lipid barrier — including:
 *   • Sphingolipid synthesis pathway (ceramide biosynthesis)
 *   • Lamellar body (LB) secretion / exocytosis
 *   • Corneocyte desquamation (cell-cycle-driven shedding)
 *   • Inflammatory cascade (NF-κB → cytokine → barrier disruption)
 *   • Barrier repair after disruption (tape-strip injury model)
 *
 * Mechanistic basis
 * ─────────────────
 * Ceramides (CER NS, CER AP, CER EOP) are synthesised in the ER via
 * the de novo serine–palmitoyl-CoA pathway, then processed in the Golgi
 * and packaged into lamellar bodies (LBs).  LBs are secreted at the
 * stratum granulosum → SC interface (exocytosis), releasing lipid
 * lamellae that form the intercellular SC barrier.
 *
 * Desquamation is driven by a cell-cycle counter multiset: when the
 * counter reaches zero the top-layer corneocyte tile is destroyed.
 *
 * Inflammatory cytokines (IL-1β, TNF-α) downregulate LB exocytosis and
 * directly modify SC glue strength, increasing permeability.
 *
 * References: Elias (2012) J. Invest. Derm.; Feingold (2009) JLBR;
 *             Schmitt et al. (2019) Skin Pharmacol. Physiol.
 *
 * Run:
 *   bin/mlingua examples/skin/barrier_repair.mli -o /tmp/barrier_repair.msim
 *   bin/msim /tmp/barrier_repair.msim -steps 600 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Glue definitions ─────────────────────────────────────────────── */
    @glue glue_cer;     /* ceramide-enriched lipid bilayer glue          */
    @glue glue_weak;    /* disrupted / ceramide-depleted barrier glue    */
    @glue glue_tj;      /* tight junction (granulosum ↔ SC interface)    */
    @glue glue_dsg;     /* desmoglein adhesion (SC–SC lateral)           */
    @glue glue_air;     /* air-facing non-reactive glue                  */

    /* Healthy SC bilayer bonds to itself */
    @glue_relation(glue_cer,  glue_cer);
    /* Weakened bilayer after inflammation */
    @glue_relation(glue_weak, glue_weak);
    /* Mixed: healthy–weakened junction (barrier disruption front) */
    @glue_relation(glue_cer,  glue_weak);
    /* Tight junction sealing at granulosum */
    @glue_relation(glue_tj,   glue_tj);
    /* Desmosomal adhesion */
    @glue_relation(glue_dsg,  glue_dsg);

    @glue_radius 0.10;

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sc_healthy
     *
     * SC corneocyte tile with intact ceramide-rich lipid lamellae.
     * Lateral connectors carry glue_cer (healthy barrier).
     * Counter multiset (cc_5) drives desquamation after 5 cell cycles.
     */
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
        /* Cell-cycle counter protions — 5 represent 5 transit-amplifying cycles */
        @protion p_cc at ( 4,  4);
        @protion p_cc at ( 4, -4);
        @protion p_cc at (-4,  4);
        @protion p_cc at (-4, -4);
        @protion p_cc at ( 0,  0);
        /* Serine palmitoyltransferase (SPT) — de novo ceramide synthesis */
        @protion p_spt at (2, 0);
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sc_inflamed
     *
     * SC corneocyte tile with disrupted lipid lamellae.
     * Lateral connectors carry glue_weak (high-permeability barrier).
     * Produced by inflammatory cytokines replacing sc_healthy tile.
     */
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
        /* Reduced SPT activity in inflamed state */
        @protion p_spt at (0, 0);
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: granular_cell
     *
     * Stratum granulosum keratinocyte — contains lamellar bodies ready
     * for exocytosis.  Sits immediately below SC layer.
     * Lamellar body secretion protions (p_lb) on apical face.
     */
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
        /* Lamellar body exocytosis sites on apical face */
        @protion p_lb at ( 3,  3);
        @protion p_lb at (-3,  3);
        @protion p_lb at ( 0,  4);
        /* Glucocerebrosidase (GBA) for ceramide processing */
        @protion p_gba at (0, -2);
        /* NF-κB nuclear receptor (cytokine sensor) */
        @protion p_nfkb at (-3, -3);
    }

    @seed sc_healthy at (0, 0, 0);
}

/* ── Floating objects ─────────────────────────────────────────────────── */

/* Sphingolipid synthesis intermediates */
@floating serine(mobility=6, radius=0.03, concentration=20);
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=15);
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

/* Lamellar body contents */
@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Inflammatory cytokines */
@floating il1b(mobility=7, radius=0.04, concentration=0);   /* IL-1β */
@floating tnfa(mobility=7, radius=0.04, concentration=0);   /* TNF-α */
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);

/* Desquamation enzyme */
@floating ksc(mobility=4, radius=0.05, concentration=2);    /* kallikrein-5 */
@floating cdsn(mobility=1, radius=0.10, concentration=5);   /* corneodesmosin */

/* Repair signals */
@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_cc;      /* cell-cycle counter on sc_healthy corneocyte  */
@protion p_spt;     /* serine palmitoyltransferase (SPT)            */
@protion p_lb;      /* lamellar body exocytosis site                */
@protion p_gba;     /* glucocerebrosidase (GBA)                     */
@protion p_nfkb;    /* NF-κB nuclear receptor sensor                */

/* ── Sigma: release mappings ─────────────────────────────────────────── */
/*
 * When sc_healthy connects to granular_cell (glue_tj pair),
 * lamellar bodies release ceramide into the intercellular space.
 */
@sigma(glue_tj, glue_tj) = ceramide, ceramide, ceramide;

/*
 * When sc_inflamed meets sc_healthy (mixed-glue barrier-disruption front),
 * release IL-1β to propagate inflammation signal laterally.
 */
@sigma(glue_weak, glue_cer) = il1b, il1b;

@reaction_distance 14;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ══════════════════════════════════════════════════════════════════
     * SPHINGOLIPID SYNTHESIS PATHWAY (de novo, ER-localised)
     * ══════════════════════════════════════════════════════════════════
     *
     * Step 1: SPT (p_spt protion) condenses serine + palmitoyl-CoA
     *         → 3-ketosphingananine (simplified to sphinganine)
     */
    p_spt: serine, palmitoyl_coa --> sphinganine;

    /*
     * Step 2: Sphinganine → dihydroceramide (ceramide synthase)
     * Fatty acid (fa) acylates sphinganine backbone.
     */
    sphinganine --> dihydroceramide;

    /*
     * Step 3: Dihydroceramide desaturase → ceramide
     * Rate-limiting step; encoded as direct conversion rule.
     */
    dihydroceramide --> ceramide;

    /*
     * Step 4: GBA (p_gba protion) converts glucosylceramide → ceramide
     * (salvage / recycling pathway, active in granulosum)
     */
    p_gba: glucosylceramide --> ceramide;

    /* ══════════════════════════════════════════════════════════════════
     * LAMELLAR BODY EXOCYTOSIS
     * ══════════════════════════════════════════════════════════════════
     *
     * p_lb protion packages ceramide into lamellar body vesicles (lb_vesicle)
     * and releases them at the granulosum–SC interface.
     */
    p_lb: ceramide, ceramide, ceramide --> lb_vesicle;
    p_lb: lb_vesicle --> ceramide, ceramide, ceramide;   /* vesicle fusion */

    /* ══════════════════════════════════════════════════════════════════
     * CORNEOCYTE DESQUAMATION (cell-cycle counter)
     * ══════════════════════════════════════════════════════════════════
     *
     * Kallikrein-5 (ksc) cleaves corneodesmosin (cdsn) — the corneodesmosome
     * adhesion protein.  Each cleavage decrements one p_cc counter token.
     * When all 5 counters are consumed the tile is destroyed (desquamated).
     *
     * p_cc counter: consumed one-by-one by ksc + cdsn → cdsn_cleaved
     */
    p_cc: ksc, cdsn --> cdsn_cleaved;

    /* Corneocyte desquamation: destroy sc_healthy when fully processed
     * (modelled as destroy rule triggered by the terminal dsq_signal object)
     */
    @destroy dsq_signal, sc_healthy --> serine, serine, repair_signal;

    /* dsq_signal released when cdsn_cleaved accumulates (5 copies) */
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* ══════════════════════════════════════════════════════════════════
     * INFLAMMATORY CASCADE (NF-κB pathway)
     * ══════════════════════════════════════════════════════════════════
     *
     * IL-1β or TNF-α activates NF-κB nuclear receptor (p_nfkb protion).
     * Active NF-κB drives transcription of pro-inflammatory cytokines and
     * downregulates ceramide synthesis (barrier disruption).
     */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;

    /* NF-κB positive feedback: produces more IL-1β + TNF-α */
    nfkb_active --> il1b, tnfa, nfkb_active;

    /* NF-κB inhibits SPT activity (downregulates ceramide synthesis) */
    nfkb_active, ceramide --> nfkb_active;     /* ceramide consumed faster  */

    /* ── Inflammatory tile replacement ───────────────────────────────
     * Sustained NF-κB activation converts healthy → inflamed corneocyte.
     * @create / @destroy pair models the replacement.
     */
    @create nfkb_active, nfkb_active, sc_healthy --> sc_inflamed;
    @destroy nfkb_active, sc_inflamed --> il1b, tnfa;

    /* ══════════════════════════════════════════════════════════════════
     * BARRIER REPAIR
     * ══════════════════════════════════════════════════════════════════
     *
     * Repair signal (from desquamation, tape-strip, or injury) upregulates
     * ceramide synthesis and LB exocytosis (homeostatic feedback loop).
     * Ceramide accumulates → sc_healthy tile re-assembled.
     */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;

    /* Repair signal also inhibits NF-κB cascade */
    repair_signal, nfkb_active --> repair_signal;

    /* ── Granular cell: basal supply of synthesis substrates ─────────
     * Granular cells continuously supply ceramide synthesis substrates.
     */
    @create serine, serine, palmitoyl_coa, palmitoyl_coa --> granular_cell;
    @destroy repair_signal, granular_cell --> serine, serine,
                                              palmitoyl_coa, palmitoyl_coa;
}
