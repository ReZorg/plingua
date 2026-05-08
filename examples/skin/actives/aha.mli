/*
 * aha.mli — Phase 4: Alpha-Hydroxy Acid (AHA) Active Ingredient Module
 *
 * Models the pH-dependent keratolytic and barrier-modulating activity of
 * alpha-hydroxy acids (AHAs) — primarily glycolic acid (GA) and lactic
 * acid (LA).
 *
 * Physicochemical properties:
 *   Glycolic acid:  log P = −1.1, MW = 76.05 Da, pKa = 3.83
 *   Lactic acid:    log P = −0.7, MW = 90.08 Da, pKa = 3.86
 *   Mandelic acid:  log P =  0.5, MW = 152.1 Da, pKa = 3.41
 *
 * AHAs are weak acids; skin pH determines the protonated (membrane-
 * permeable) vs. ionised (membrane-impermeant) fraction via the
 * Henderson–Hasselbalch equation.  At formulation pH 3.5–4.0,
 * approximately 10–25% is protonated (permeable form).
 *
 * Mechanistic effects modelled
 * ─────────────────────────────
 *   1. pH-dependent corneodesmolysis (desquamation acceleration)
 *      AHAs lower intercellular pH → activate kallikrein (serine protease)
 *      → cleave corneodesmosomes → increase exfoliation rate.
 *
 *   2. Calcium sequestration in stratum spinosum
 *      Ionic AHA (lactate) chelates Ca²⁺ → loosens desmosomes →
 *      increases epidermal cell turnover.
 *
 *   3. Collagen stimulation (indirect, post-exfoliation)
 *      Accelerated cell turnover → TGF-β upregulation → pro-collagen
 *      synthesis in dermis.
 *
 *   4. Barrier modulation: transient TEWL increase then barrier repair
 *      Phase 1: AHA reduces SC thickness (exfoliation) → TEWL↑
 *      Phase 2: fresh corneocytes with intact ceramide layers → TEWL↓
 *
 * Reference: Van Scott & Yu (1984) JADA; Smith (1996) Dermatol. Clin.;
 *            Tang et al. (1998) JID.
 *
 * Run:
 *   bin/mlingua examples/skin/actives/aha.mli -o /tmp/aha.msim
 *   bin/msim /tmp/aha.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Glues ─────────────────────────────────────────────────────────── */
    @glue glue_dsg_intact;   /* Intact desmoglein adhesion               */
    @glue glue_dsg_cleaved;  /* Cleaved / weakened desmoglein            */
    @glue glue_acid;         /* Low-pH acid-conditioned interface        */
    @glue glue_neutral;      /* Neutral pH SC interface                  */
    @glue glue_air;

    @glue_relation(glue_dsg_intact,  glue_dsg_intact);
    @glue_relation(glue_dsg_cleaved, glue_dsg_cleaved);
    /* Acid-front: intact meets cleaved at exfoliation boundary */
    @glue_relation(glue_dsg_intact,  glue_dsg_cleaved);
    @glue_relation(glue_acid,    glue_acid);
    @glue_relation(glue_neutral, glue_neutral);

    @glue_radius 0.10;

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sc_normal
     *
     * Intact SC corneocyte with normal desmoglein adhesion.
     * Cell-cycle counter (p_cc) encoded as protion (5 counts).
     */
    @tile sc_normal(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_dsg_intact, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_dsg_intact, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_dsg_intact, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_dsg_intact, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_dsg_intact, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_dsg_intact, angle=60);
        @connector c_top(vertices=[center], glue=glue_neutral, angle=90);
        @connector c_base(vertices=[center], glue=glue_neutral, angle=-90);
        @surface_glue glue_air;
        @color Wheat alpha=200;
        @protion p_cc   at ( 3,  3);
        @protion p_cc   at ( 3, -3);
        @protion p_cc   at (-3,  3);
        @protion p_cc   at (-3, -3);
        @protion p_cc   at ( 0,  0);
        @protion p_ksc  at ( 0,  4);   /* Kallikrein-5 (serine protease)  */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sc_acid_softened
     *
     * AHA-conditioned SC corneocyte with weakened desmoglein bonds.
     * Increased permeability to both hydrophilic and lipophilic drugs.
     */
    @tile sc_acid_softened(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_dsg_cleaved, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_dsg_cleaved, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_dsg_cleaved, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_dsg_cleaved, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_dsg_cleaved, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_dsg_cleaved, angle=60);
        @connector c_top(vertices=[center], glue=glue_acid, angle=90);
        @connector c_base(vertices=[center], glue=glue_acid, angle=-90);
        @surface_glue glue_air;
        @color PeachPuff alpha=180;
        @protion p_ksc  at ( 0,  0);   /* Elevated kallikrein activity   */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: fresh_corneocyte
     *
     * Newly differentiated SC cell after exfoliation.
     * Ceramide-rich lamellae, tight desmoglein bonds.
     */
    @tile fresh_corneocyte(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_dsg_intact, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_dsg_intact, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_dsg_intact, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_dsg_intact, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_dsg_intact, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_dsg_intact, angle=60);
        @connector c_top(vertices=[center], glue=glue_neutral, angle=90);
        @connector c_base(vertices=[center], glue=glue_neutral, angle=-90);
        @surface_glue glue_air;
        @color LightYellow alpha=200;
        @protion p_cc at (0, 0);
        @protion p_cc at (2, 2);
        @protion p_cc at (2, -2);
        @protion p_cc at (-2, 2);
        @protion p_cc at (-2, -2);
    }

    @seed sc_normal at (0, 0, 0);
}

/* ── Floating objects ─────────────────────────────────────────────────── */

/* AHA forms (protonated = membrane-permeable, ionised = aqueous retained) */
@floating ga_protonated(mobility=5.0, radius=0.03, concentration=15);  /* GA protonated */
@floating ga_ionised(mobility=6.0, radius=0.03, concentration=35);     /* GA ionised    */
@floating la_protonated(mobility=4.5, radius=0.03, concentration=10);  /* LA protonated */
@floating la_ionised(mobility=5.5, radius=0.03, concentration=20);

/* Proton (H⁺) — acidic pH signal */
@floating hplus(mobility=9, radius=0.02, concentration=20);  /* [H⁺] ∝ 10^−pH */

/* Desmoglein proteolysis intermediates */
@floating cdsn(mobility=1, radius=0.10, concentration=8);      /* corneodesmosin */
@floating cdsn_cleaved(mobility=2, radius=0.08, concentration=0);
@floating dsg1(mobility=1, radius=0.12, concentration=6);      /* desmoglein-1   */
@floating dsg1_cleaved(mobility=2, radius=0.08, concentration=0);

/* Kallikrein enzymes */
@floating ksc(mobility=4, radius=0.05, concentration=3);      /* kallikrein-5  */
@floating ksc_active(mobility=4, radius=0.05, concentration=0);

/* Calcium (Ca²⁺) — desmosome integrity regulator */
@floating ca2p(mobility=5, radius=0.03, concentration=10);
@floating ca2p_chelated(mobility=3, radius=0.06, concentration=0);

/* Post-exfoliation repair signals */
@floating tgfb(mobility=4, radius=0.07, concentration=0);    /* TGF-β          */
@floating collagen_pre(mobility=1.5, radius=0.12, concentration=0);

/* Ceramide (barrier repair signal) */
@floating ceramide(mobility=2, radius=0.07, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_cc;
@protion p_ksc;

/* ── Sigma ───────────────────────────────────────────────────────────── */
/* When acid-softened tile meets intact tile: AHA front advances, releasing H⁺ */
@sigma(glue_dsg_cleaved, glue_dsg_intact) = hplus, hplus;

/* After exfoliation, repair signal released from fresh basal layer */
@sigma(glue_neutral, glue_neutral) = tgfb, ceramide;

@reaction_distance 11;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ══════════════════════════════════════════════════════════════════
     * pH-DEPENDENT AHA EQUILIBRIUM
     * ══════════════════════════════════════════════════════════════════
     *
     * Henderson–Hasselbalch: at pH 3.5, ~25% of GA (pKa 3.83) is protonated.
     * Encoded as a probabilistic conversion between forms.
     */
    /* AHA protonation: driven by excess H⁺ (low pH environment) */
    hplus, ga_ionised  --> ga_protonated;
    hplus, la_ionised  --> la_protonated;

    /* AHA deprotonation: releases H⁺ at higher skin pH */
    ga_protonated --> ga_ionised, hplus;
    la_protonated --> la_ionised, hplus;

    /* ══════════════════════════════════════════════════════════════════
     * KALLIKREIN-5 ACTIVATION BY ACID pH
     * ══════════════════════════════════════════════════════════════════
     *
     * Protonated AHA directly acidifies SC intercellular space →
     * pH optimum for KSC (kallikrein-5) is ~5.5; lower pH further
     * activates it.  H⁺ tokens represent the local acid signal.
     */
    p_ksc: hplus, ksc --> ksc_active;
    p_ksc: ga_protonated, ksc --> ksc_active;

    /* ══════════════════════════════════════════════════════════════════
     * CORNEODESMOLYSIS — DESMOGLEIN + CORNEODESMOSIN CLEAVAGE
     * ══════════════════════════════════════════════════════════════════
     *
     * KSC (ksc_active) cleaves CDSN and DSG1 → desquamation.
     */
    p_ksc: ksc_active, cdsn  --> ksc_active, cdsn_cleaved;
    p_ksc: ksc_active, dsg1  --> ksc_active, dsg1_cleaved;

    /* ══════════════════════════════════════════════════════════════════
     * CALCIUM SEQUESTRATION (ionised lactate / glycolate)
     * ══════════════════════════════════════════════════════════════════
     *
     * Lactate ionised form (la_ionised) chelates Ca²⁺ →
     * Ca²⁺ depletion loosens Ca²⁺-dependent desmosomes.
     */
    la_ionised, ca2p --> ca2p_chelated, la_ionised;

    /* Low Ca²⁺ destabilises desmoglein bonds (modelled as rule consuming cdsn) */
    ca2p_chelated, cdsn --> cdsn_cleaved, ca2p_chelated;

    /* ══════════════════════════════════════════════════════════════════
     * TILE CONVERSION: normal → acid-softened → desquamation
     * ══════════════════════════════════════════════════════════════════
     *
     * When sufficient cleavage (5 cdsn_cleaved + 3 dsg1_cleaved) →
     * tile is acid-softened.
     */
    @create cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
            dsg1_cleaved, dsg1_cleaved, ga_protonated --> sc_acid_softened;

    /* Acid-softened tile desquamates: released fragments become repair cues */
    @destroy ksc_active, sc_acid_softened --> ceramide, tgfb, cdsn;

    /* ══════════════════════════════════════════════════════════════════
     * CELL-CYCLE COUNTER DECREMENT (p_cc)
     * ══════════════════════════════════════════════════════════════════
     *
     * AHA accelerates cell-cycle (exfoliation shortens transit time).
     * Each ga_protonated token decrements one p_cc counter.
     */
    p_cc: ga_protonated, ksc_active --> ksc_active;  /* counter consumed */

    /* Normal (non-AHA) desquamation: kallikrein + CDSN */
    p_cc: ksc, cdsn --> cdsn_cleaved;

    /* Full desquamation event: 5 counters gone → destroy sc_normal */
    @destroy ksc_active, ksc_active, ksc_active,
             ksc_active, ksc_active, sc_normal
             --> cdsn, cdsn, ceramide, tgfb;

    /* ══════════════════════════════════════════════════════════════════
     * POST-EXFOLIATION REPAIR
     * ══════════════════════════════════════════════════════════════════
     *
     * TGF-β (from sigma release after exfoliation) → new corneocytes.
     * Ceramide → barrier restoration.
     */
    @create ceramide, ceramide, ceramide, tgfb --> fresh_corneocyte;

    /* TGF-β → pro-collagen in dermis (indirect anti-ageing pathway) */
    tgfb --> collagen_pre, collagen_pre;

    /* Barrier recovery: pH neutralisation after AHA washoff */
    ceramide, ceramide, ceramide --> sc_normal;
}
