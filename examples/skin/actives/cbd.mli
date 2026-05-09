/*
 * cbd.mli — Phase 4: CBD / Phytocannabinoid Active Ingredient Module
 *
 * Models the interaction of cannabidiol (CBD) and related phytocannabinoids
 * with skin biology.  Topical CBD is used for anti-inflammatory,
 * antioxidant, and sebostatic effects.
 *
 * Physicochemical properties (CBD):
 *   log P = 6.3   (highly lipophilic — penetrates SC lipid bilayer well)
 *   MW    = 314.5 Da
 *   pKa   = 10.6  (essentially neutral at skin pH 4.5–5.5)
 *   Protein binding ≈ 90%
 *
 * Key pharmacological targets in skin
 * ─────────────────────────────────────
 *   CB1R  — Cannabinoid receptor type 1 (expressed on keratinocytes, mast cells)
 *   CB2R  — Cannabinoid receptor type 2 (expressed on immune cells, sebocytes)
 *   TRPV1 — Transient receptor potential vanilloid 1 (itch, pain, LB secretion)
 *   PPARγ — Peroxisome proliferator-activated receptor γ (anti-inflammatory)
 *
 * Effects modelled
 * ────────────────
 *   1. CB2R activation → inhibit NF-κB → reduce IL-1β / TNF-α production
 *   2. TRPV1 activation → stimulate ceramide synthesis (barrier support)
 *   3. PPARγ activation → reduce sebum production in sebocytes
 *   4. Sebostatic effect → reduces sebum lipid output from sebaceous gland
 *
 * Reference: Baswan et al. (2020) Clin. Cosmet. Investig. Dermatol.;
 *            Petrosino et al. (2018) J. Dermatol. Sci.
 *
 * Use: include or compose with skin_layers.mli and barrier_repair.mli
 *
 * Run:
 *   bin/mlingua examples/skin/actives/cbd.mli -o /tmp/cbd.msim
 *   bin/msim /tmp/cbd.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Receptor / signalling glues ──────────────────────────────────── */
    @glue glue_cb2;     /* CB2R-expressing cell surface                  */
    @glue glue_trpv1;   /* TRPV1-expressing cell surface                 */
    @glue glue_ppar;    /* PPARγ nuclear receptor glue                   */
    @glue glue_seb;     /* Sebocyte–duct glue (sebum pathway)            */
    @glue glue_kc;      /* Keratinocyte lateral glue                     */
    @glue glue_mc;      /* Mast cell–dermis glue                         */

    @glue_relation(glue_cb2,   glue_cb2);
    @glue_relation(glue_trpv1, glue_trpv1);
    @glue_relation(glue_ppar,  glue_ppar);
    @glue_relation(glue_seb,   glue_seb);
    @glue_relation(glue_kc,    glue_kc);
    @glue_relation(glue_mc,    glue_mc);

    @glue_radius 0.12;

    /* ────────────────────────────────────────────────────────────────────
     * TILE: cbd_keratinocyte
     *
     * Keratinocyte expressing CB1R, CB2R, and TRPV1.
     * CBD acts on all three receptors with different downstream effects.
     */
    @tile cbd_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_kc,    angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_kc,    angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_kc,    angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_kc,    angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_kc,    angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_kc,    angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2,   angle=90);
        @connector c_trpv1(vertices=[center], glue=glue_trpv1, angle=45);
        @surface_glue glue_kc;
        @color PaleGreen alpha=140;
        @protion p_cb2  at ( 3,  0);   /* CB2R receptor               */
        @protion p_trpv1 at (-3,  0);  /* TRPV1 channel               */
        @protion p_nfkb  at ( 0,  3);  /* NF-κB nuclear receptor      */
        @protion p_spt   at ( 0, -3);  /* Ceramide synthesis (SPT)    */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sebocyte
     *
     * Lipid-producing sebocyte cell in sebaceous gland.
     * CBD via PPARγ reduces lipogenesis.
     */
    @tile sebocyte(sides=4, radius=20) {
        @connector c1(vertices=[v1,v2], glue=glue_seb, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_seb, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_seb, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_seb, angle=90);
        @connector c_ppar(vertices=[center], glue=glue_ppar, angle=90);
        @surface_glue glue_seb;
        @color Gold alpha=130;
        @protion p_ppar  at ( 0,  3);   /* PPARγ nuclear receptor      */
        @protion p_lip   at ( 0, -3);   /* Lipid synthesis protion     */
        @protion p_androgen at (3, 0);  /* Androgen receptor (driver)  */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: mast_cell
     *
     * Dermal mast cell — inflammatory mediator.
     * CB2R on mast cell reduces histamine / IL-4 release.
     */
    @tile mast_cell(sides=6, radius=6) {
        @connector c1(vertices=[v1,v2], glue=glue_mc, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mc, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mc, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mc, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mc, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mc, angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2, angle=90);
        @surface_glue glue_mc;
        @color Plum alpha=150;
        @protion p_cb2    at (0, 2);    /* CB2R on mast cell           */
        @protion p_hist   at (0, -2);   /* Histamine release site      */
    }

    @seed cbd_keratinocyte at (0, 0, 0);
}

/* ── CBD physicochemical floating objects ─────────────────────────────── */
/*
 * cbd_free — unbound CBD in lipid phase of SC
 * Highly lipophilic; mobility in SC lipid is modest despite log P > 6.
 */
@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);

/*
 * cbd_protein — CBD bound to serum albumin / skin proteins
 * Low effective mobility (sequestered).
 */
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);

/* CBC / CBG sister cannabinoids */
@floating cbg_free(mobility=1.8, radius=0.09, concentration=5);
@floating cbc_free(mobility=1.9, radius=0.09, concentration=5);

/* Downstream signalling objects */
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating il1b(mobility=7, radius=0.04, concentration=0);
@floating tnfa(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);
@floating histamine(mobility=8, radius=0.03, concentration=0);
@floating sebum(mobility=0.8, radius=0.15, concentration=10);
@floating androgen(mobility=4, radius=0.05, concentration=3);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_cb2;
@protion p_trpv1;
@protion p_nfkb;
@protion p_spt;
@protion p_ppar;
@protion p_lip;
@protion p_androgen;
@protion p_hist;

/* ── Sigma ───────────────────────────────────────────────────────────── */
/* CB2R activation releases anti-inflammatory signal */
@sigma(glue_cb2, glue_cb2) = cb2_signal, cb2_signal;

/* TRPV1 activation releases ceramide (barrier support) */
@sigma(glue_trpv1, glue_trpv1) = ceramide, ceramide;

@reaction_distance 12;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ══════════════════════════════════════════════════════════════════
     * CB2R ACTIVATION — ANTI-INFLAMMATORY PATHWAY
     * ══════════════════════════════════════════════════════════════════
     *
     * CBD binds CB2R (p_cb2 protion) → cb2_signal →
     *   suppresses NF-κB activation →
     *   reduces IL-1β + TNF-α production
     */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;    /* CBD binds CB2R        */
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal; /* NF-κB suppressed      */

    /* Reduced cytokine production under CB2R activation */
    cb2_signal, il1b --> cb2_signal;                /* IL-1β consumed        */
    cb2_signal, tnfa  --> cb2_signal;               /* TNF-α consumed        */

    /* ══════════════════════════════════════════════════════════════════
     * TRPV1 ACTIVATION — CERAMIDE / BARRIER SUPPORT
     * ══════════════════════════════════════════════════════════════════
     *
     * CBD at high concentration activates / desensitises TRPV1 →
     * stimulates sphingolipid synthesis via p_spt protion.
     */
    p_trpv1: cbd_free --> trpv1_signal, cbd_protein;
    p_spt: trpv1_signal --> ceramide, ceramide;     /* SPT upregulation      */

    /* TRPV1-mediated mast cell degranulation suppression */
    p_trpv1: histamine, cbd_free --> histamine_blk, cbd_protein;

    /* ══════════════════════════════════════════════════════════════════
     * PPARγ ACTIVATION — SEBOSTATIC EFFECT
     * ══════════════════════════════════════════════════════════════════
     *
     * CBD activates PPARγ (p_ppar) in sebocytes →
     * suppresses androgen-driven lipid synthesis (p_lip) →
     * reduces sebum output.
     */
    p_ppar: cbd_free, androgen --> ppar_signal, cbd_protein;
    p_lip: ppar_signal, sebum  --> ppar_signal;     /* sebum production halt */

    /* Without CBD: androgen drives sebum production normally */
    p_androgen: androgen --> sebum, sebum;

    /* With CBD/PPARγ: androgen response blunted */
    p_ppar: ppar_signal, androgen --> ppar_signal;

    /* ══════════════════════════════════════════════════════════════════
     * MAST CELL CB2R — ANTI-ITCH / ANTI-ALLERGIC
     * ══════════════════════════════════════════════════════════════════
     *
     * CB2R on mast cell (p_cb2) + CBD → cb2_signal → inhibits
     * histamine (p_hist) and IL-4 release.
     */
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* CBD protein binding and release */
    cbd_protein --> cbd_free;                       /* slow release          */

    /* ══════════════════════════════════════════════════════════════════
     * TILE ASSEMBLY / DISASSEMBLY
     * ══════════════════════════════════════════════════════════════════
     */
    @create ceramide, ceramide, ceramide --> cbd_keratinocyte;
    @create sebum, sebum, androgen       --> sebocyte;
    @create il1b, tnfa                   --> mast_cell;

    /* CBD promotes keratinocyte survival (anti-apoptotic) */
    @destroy tnfa, tnfa, cbd_free, cbd_keratinocyte --> ceramide, cb2_signal;
}
