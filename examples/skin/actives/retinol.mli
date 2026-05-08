/*
 * retinol.mli — Phase 4: Retinoid Active Ingredient Module
 *
 * Models the transdermal delivery and skin-biological activity of retinol
 * (vitamin A alcohol) and its metabolic conversion cascade in the skin.
 *
 * Physicochemical properties (retinol):
 *   log P = 5.7   (highly lipophilic — excellent SC penetration)
 *   MW    = 286.5 Da
 *   pKa   = N/A   (neutral alcohol)
 *   Protein binding (CRABP-II, RBP) ≈ 95%
 *
 * Retinoid metabolic cascade in skin
 * ─────────────────────────────────────
 *   Retinol (ROH)
 *     → Retinaldehyde (RAL)     [via RDH10 / RDHE2 — retinol dehydrogenases]
 *     → Retinoic acid (RA)      [via RALDH — aldehyde dehydrogenase]
 *     → RA–CRABP-II complex     [cytoplasmic binding protein]
 *     → RAR/RXR nuclear receptor activation
 *     → RARE transcription of: collagen, filaggrin, involucrin, loricrin
 *
 * Key pharmacological effects
 * ────────────────────────────
 *   1. Stimulate collagen I + III synthesis in fibroblasts (anti-wrinkle)
 *   2. Increase epidermal cell turnover (proliferation + differentiation)
 *   3. Inhibit MMP (matrix metalloproteinase) expression (anti-photoageing)
 *   4. Regulate cornification (filaggrin, involucrin, loricrin → barrier)
 *   5. Reduce melanosome transfer (slight skin-tone evening)
 *
 * Reference: Mukherjee et al. (2006) Clin. Interv. Aging;
 *            Zasada & Budzisz (2019) Postepy Dermatol. Alergol.
 *
 * Run:
 *   bin/mlingua examples/skin/actives/retinol.mli -o /tmp/retinol.msim
 *   bin/msim /tmp/retinol.msim -steps 500 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Signalling glues ─────────────────────────────────────────────── */
    @glue glue_ker;     /* Keratinocyte lateral glue                     */
    @glue glue_fib;     /* Fibroblast lateral / ECM glue                 */
    @glue glue_nuc;     /* Nuclear membrane glue (RAR/RXR binding)       */
    @glue glue_ecm;     /* Extracellular matrix connector                */
    @glue glue_air;     /* Air-facing surface                            */

    @glue_relation(glue_ker, glue_ker);
    @glue_relation(glue_fib, glue_fib);
    @glue_relation(glue_nuc, glue_nuc);
    @glue_relation(glue_ecm, glue_ecm);

    @glue_radius 0.12;

    /* ────────────────────────────────────────────────────────────────────
     * TILE: retinoid_keratinocyte
     *
     * Keratinocyte expressing RDH10 (retinol → retinaldehyde),
     * RALDH (retinaldehyde → RA), CRABP-II, and RAR/RXR.
     */
    @tile retinoid_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_ker, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_ker, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_ker, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_ker, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_ker, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_ker, angle=60);
        @connector c_nuc(vertices=[center], glue=glue_nuc, angle=90);
        @surface_glue glue_ker;
        @color PaleGoldenrod alpha=180;
        @protion p_rdh   at ( 3,  3);   /* RDH10 / RDHE2 dehydrogenase */
        @protion p_raldh at (-3,  3);   /* Aldehyde dehydrogenase      */
        @protion p_crabp at ( 0,  0);   /* CRABP-II binding protein    */
        @protion p_rar   at ( 0,  4);   /* RAR/RXR nuclear receptor    */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: retinoid_fibroblast
     *
     * Dermal fibroblast expressing RAR, RXR, and collagen synthetic
     * machinery.  Retinoic acid upregulates pro-collagen I + III.
     */
    @tile retinoid_fibroblast(sides=8, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_fib, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fib, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fib, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fib, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fib, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fib, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fib, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fib, angle=45);
        @connector c_ecm(vertices=[center], glue=glue_ecm, angle=90);
        @connector c_nuc(vertices=[center], glue=glue_nuc, angle=-90);
        @surface_glue glue_fib;
        @color Tan alpha=160;
        @protion p_rar   at ( 0,  4);   /* RAR/RXR nuclear receptor    */
        @protion p_col   at ( 0, -4);   /* Collagen synthesis site     */
        @protion p_mmp   at ( 3,  0);   /* MMP (collagen breakdown)    */
    }

    @seed retinoid_keratinocyte at (0, 0, 0);
}

/* ── Floating objects ─────────────────────────────────────────────────── */

/* Retinoid cascade intermediates */
@floating retinol(mobility=2.0, radius=0.08, concentration=30);   /* ROH */
@floating retinaldehyde(mobility=2.5, radius=0.08, concentration=0);
@floating retinoic_acid(mobility=3.0, radius=0.07, concentration=0);
@floating crabp_complex(mobility=1.0, radius=0.15, concentration=0);

/* Retinyl ester storage (excess retinol esterified in sebocytes) */
@floating retinyl_ester(mobility=0.5, radius=0.12, concentration=5);

/* RAR/RXR transcription targets */
@floating collagen_pre(mobility=1.5, radius=0.12, concentration=0);  /* pro-collagen */
@floating filaggrin(mobility=2.0, radius=0.10, concentration=0);
@floating involucrin(mobility=2.0, radius=0.10, concentration=0);
@floating loricrin(mobility=2.0, radius=0.10, concentration=0);

/* MMP (collagen-degrading enzymes) */
@floating mmp1(mobility=4, radius=0.06, concentration=5);
@floating mmp3(mobility=4, radius=0.06, concentration=3);

/* ECM components */
@floating collagen_i(mobility=0.5, radius=0.20, concentration=0);
@floating collagen_iii(mobility=0.5, radius=0.20, concentration=0);

/* Irritation marker (retinoid dermatitis metabolite) */
@floating irritation_signal(mobility=6, radius=0.04, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_rdh;
@protion p_raldh;
@protion p_crabp;
@protion p_rar;
@protion p_col;
@protion p_mmp;

/* ── Sigma ───────────────────────────────────────────────────────────── */
/* RAR/RXR nuclear activation releases collagen pre-mRNA proxy */
@sigma(glue_nuc, glue_nuc) = collagen_pre, filaggrin;

@reaction_distance 12;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ══════════════════════════════════════════════════════════════════
     * RETINOID METABOLIC CASCADE
     * ══════════════════════════════════════════════════════════════════
     *
     * Step 1: Retinol → Retinaldehyde (RDH10, reversible)
     */
    p_rdh:   retinol        --> retinaldehyde;
    p_rdh:   retinaldehyde  --> retinol;           /* reversible         */

    /*
     * Step 2: Retinaldehyde → Retinoic acid (RALDH, irreversible)
     * Rate-limiting step in RA production.
     */
    p_raldh: retinaldehyde  --> retinoic_acid;

    /*
     * Step 3: CRABP-II binds RA → delivers to RAR nucleus
     */
    p_crabp: retinoic_acid  --> crabp_complex;
    p_crabp: crabp_complex  --> retinoic_acid;     /* slow release       */

    /*
     * Step 4: RAR/RXR activation by RA (p_rar protion)
     * Transcriptional cascade → collagen, filaggrin, involucrin, loricrin
     */
    p_rar: crabp_complex --> rar_active, retinoic_acid;
    rar_active --> collagen_pre, filaggrin, involucrin, loricrin;

    /* Retinol esterification (storage / buffering) */
    retinol, retinol --> retinyl_ester;
    retinyl_ester    --> retinol;                  /* mobilisation       */

    /* ══════════════════════════════════════════════════════════════════
     * COLLAGEN SYNTHESIS (Fibroblast RAR pathway)
     * ══════════════════════════════════════════════════════════════════
     */
    p_rar: crabp_complex --> rar_active;
    p_col: collagen_pre, rar_active --> collagen_i, collagen_iii;

    /* ══════════════════════════════════════════════════════════════════
     * MMP INHIBITION (Anti-photoageing)
     * ══════════════════════════════════════════════════════════════════
     *
     * Retinoic acid suppresses MMP1 and MMP3 gene expression.
     * MMP-driven collagen breakdown is inhibited.
     */
    p_mmp: mmp1, retinoic_acid --> mmp1_blk, retinoic_acid;
    p_mmp: mmp3, retinoic_acid --> mmp3_blk, retinoic_acid;

    /* Without RA: MMPs degrade collagen */
    p_mmp: mmp1, collagen_i   --> mmp1;            /* collagen breakdown  */
    p_mmp: mmp3, collagen_iii --> mmp3;

    /* ══════════════════════════════════════════════════════════════════
     * KERATINOCYTE DIFFERENTIATION (barrier proteins)
     * ══════════════════════════════════════════════════════════════════
     *
     * Filaggrin, involucrin, and loricrin contribute to cornified envelope.
     * Cornified envelope (ce) contributes to SC integrity.
     */
    filaggrin, involucrin, loricrin --> cornified_envelope;

    /* ══════════════════════════════════════════════════════════════════
     * IRRITATION / RETINOID DERMATITIS SIGNAL
     * ══════════════════════════════════════════════════════════════════
     *
     * High RA concentration generates irritation signal (retinoid dermatitis).
     * Encoded as threshold-dependent rule (3 RA tokens → irritation).
     */
    retinoic_acid, retinoic_acid, retinoic_acid --> irritation_signal, retinoic_acid;

    /* ══════════════════════════════════════════════════════════════════
     * TILE ASSEMBLY
     * ══════════════════════════════════════════════════════════════════
     */
    @create collagen_pre, collagen_pre, collagen_pre --> retinoid_fibroblast;
    @create filaggrin, involucrin, loricrin           --> retinoid_keratinocyte;
    @destroy irritation_signal, retinoid_keratinocyte
             --> retinol, irritation_signal;           /* cell turnover      */
}
