/*
 * niacinamide.mli — Phase 4: Niacinamide Active Ingredient Module
 *
 * Models the multi-pathway activity of niacinamide (nicotinamide,
 * vitamin B3 amide) in skin biology.
 *
 * Physicochemical properties:
 *   log P = −0.37  (highly hydrophilic — excellent aqueous penetration)
 *   MW    = 122.1 Da
 *   pKa   = 3.3 (amide N, essentially neutral at skin pH)
 *   Protein binding ≈ negligible
 *
 * Key metabolic / pharmacological pathways
 * ─────────────────────────────────────────
 *   1. NAD⁺ precursor pathway
 *      Niacinamide → NMN (NMN synthetase) → NAD⁺ (NMNAT)
 *      NAD⁺ feeds sirtuins (SIRT1–3), PARPs, and cellular energy metabolism.
 *
 *   2. Melanin transfer inhibition
 *      Blocks melanosome transfer from melanocyte → keratinocyte
 *      via protease-activated receptor 2 (PAR-2) suppression.
 *      Results in skin tone evening / hyperpigmentation treatment.
 *
 *   3. Anti-inflammatory: reduces IL-8, MCP-1, TNF-α from keratinocytes
 *      (NAD⁺-dependent SIRT1 deacetylation of NF-κB p65)
 *
 *   4. Barrier: upregulates ceramide, cholesterol, fatty acid synthesis
 *      (indirect via PPARα activation)
 *
 *   5. Anti-glycation: inhibits non-enzymatic glycosylation of collagen
 *      (directly traps methylglyoxal, a reactive carbonyl species)
 *
 * Reference: Boo (2021) Cosmetics; Bissett et al. (2005) IJCD;
 *            Gehring (2004) Int. J. Cosmet. Sci.
 *
 * Run:
 *   bin/mlingua examples/skin/actives/niacinamide.mli -o /tmp/niacinamide.msim
 *   bin/msim /tmp/niacinamide.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Glues ─────────────────────────────────────────────────────────── */
    @glue glue_ker;     /* Keratinocyte lateral                          */
    @glue glue_mel;     /* Melanocyte–keratinocyte synapse glue          */
    @glue glue_fib;     /* Fibroblast lateral                            */
    @glue glue_nuc;     /* Nuclear / sirtuin compartment                 */
    @glue glue_air;

    @glue_relation(glue_ker, glue_ker);
    @glue_relation(glue_mel, glue_mel);
    @glue_relation(glue_fib, glue_fib);
    @glue_relation(glue_nuc, glue_nuc);

    @glue_radius 0.12;

    /* ────────────────────────────────────────────────────────────────────
     * TILE: niacin_keratinocyte
     *
     * Keratinocyte with NAD⁺ synthesis machinery and PAR-2 receptor.
     */
    @tile niacin_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_ker, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_ker, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_ker, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_ker, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_ker, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_ker, angle=60);
        /* Melanosome synapse connector */
        @connector c_mel(vertices=[center], glue=glue_mel, angle=90);
        @connector c_nuc(vertices=[center], glue=glue_nuc, angle=-90);
        @surface_glue glue_ker;
        @color Bisque alpha=180;
        @protion p_nmns  at ( 3,  0);   /* NMN synthetase              */
        @protion p_nmnat at (-3,  0);   /* NMNAT (NMN → NAD⁺)         */
        @protion p_sirt1 at ( 0,  3);   /* SIRT1 (NAD⁺-dependent)     */
        @protion p_par2  at ( 0, -3);   /* PAR-2 (melanosome transfer) */
        @protion p_nfkb  at ( 2,  2);   /* NF-κB sensor               */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: melanocyte
     *
     * Melanocyte synthesising eumelanin / phaeomelanin and packaging
     * into melanosomes for transfer to keratinocytes.
     */
    @tile melanocyte(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_mel, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mel, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mel, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mel, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mel, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mel, angle=60);
        /* Dendrite tips extend to keratinocytes */
        @connector c_dendrite(vertices=[center], glue=glue_mel, angle=90);
        @surface_glue glue_mel;
        @color SaddleBrown alpha=200;
        @protion p_tyr   at ( 0,  3);   /* Tyrosinase (melanin synthesis) */
        @protion p_msom  at ( 0, -3);   /* Melanosome packaging          */
        @protion p_mc1r  at ( 3,  0);   /* MC1R (MSH receptor)           */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: niacin_fibroblast
     *
     * Fibroblast with NAD⁺ metabolism and anti-glycation activity.
     */
    @tile niacin_fibroblast(sides=8, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_fib, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fib, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fib, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fib, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fib, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fib, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fib, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fib, angle=45);
        @connector c_nuc(vertices=[center], glue=glue_nuc, angle=90);
        @surface_glue glue_fib;
        @color Wheat alpha=150;
        @protion p_parp   at (0,  3);   /* PARP (DNA repair, NAD⁺ consumer) */
        @protion p_col    at (0, -3);   /* Collagen synthesis               */
        @protion p_glyc   at (3,  0);   /* Glycation site on collagen       */
    }

    @seed niacin_keratinocyte at (0, 0, 0);
}

/* ── Floating objects ─────────────────────────────────────────────────── */

/* Niacinamide (NIA) and NAD⁺ pathway */
@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);       /* NMN */
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);  /* NAD⁺ */
@floating nadh(mobility=4.0, radius=0.06, concentration=0);      /* NADH */

/* Melanin pathway */
@floating tyrosine(mobility=6, radius=0.04, concentration=10);
@floating dopa(mobility=5, radius=0.05, concentration=0);
@floating dopaquinone(mobility=5, radius=0.05, concentration=0);
@floating eumelanin(mobility=0.5, radius=0.25, concentration=0);
@floating melanosome(mobility=0.8, radius=0.30, concentration=0);
@floating alpha_msh(mobility=7, radius=0.04, concentration=3);   /* MC1R ligand */

/* PAR-2 signalling */
@floating par2_signal(mobility=6, radius=0.04, concentration=5);
@floating par2_blocked(mobility=6, radius=0.04, concentration=0);

/* Inflammatory */
@floating il8(mobility=7, radius=0.04, concentration=0);
@floating mcp1(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);

/* Anti-glycation */
@floating methylglyoxal(mobility=6, radius=0.03, concentration=5);   /* RCS */
@floating collagen_glycated(mobility=0.3, radius=0.25, concentration=0);

/* Barrier lipids (PPARα pathway, indirect) */
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating cholesterol(mobility=1.5, radius=0.08, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_nmns;
@protion p_nmnat;
@protion p_sirt1;
@protion p_par2;
@protion p_nfkb;
@protion p_tyr;
@protion p_msom;
@protion p_mc1r;
@protion p_parp;
@protion p_col;
@protion p_glyc;

/* ── Sigma ───────────────────────────────────────────────────────────── */
/* Melanosome transfer synapse: melanocyte–keratinocyte bond releases melanosome */
@sigma(glue_mel, glue_mel) = melanosome, melanosome;

/* SIRT1 nuclear activation releases NAD⁺-dependent anti-inflammatory signal */
@sigma(glue_nuc, glue_nuc) = nad_plus, ceramide;

@reaction_distance 12;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ══════════════════════════════════════════════════════════════════
     * NAD⁺ BIOSYNTHESIS PATHWAY
     * ══════════════════════════════════════════════════════════════════
     *
     * Step 1: Niacinamide → NMN (NMN synthetase, p_nmns)
     */
    p_nmns: niacinamide --> nmn;

    /*
     * Step 2: NMN → NAD⁺ (NMNAT, p_nmnat)
     */
    p_nmnat: nmn --> nad_plus;

    /* NAD⁺ ⇌ NADH (redox cycling) */
    nad_plus --> nadh;
    nadh     --> nad_plus;

    /* PARP consumes NAD⁺ during DNA repair */
    p_parp: nad_plus --> nadh, nadh;                /* PARP activation   */

    /* ══════════════════════════════════════════════════════════════════
     * SIRT1 ANTI-INFLAMMATORY PATHWAY (NAD⁺-dependent)
     * ══════════════════════════════════════════════════════════════════
     *
     * SIRT1 (p_sirt1) deacetylates NF-κB p65 → reduces IL-8, MCP-1, TNF-α
     */
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    nfkb_active --> il8, mcp1;                       /* baseline cytokines */
    p_sirt1: nad_plus, il8  --> nad_plus;            /* SIRT1 suppresses   */
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    /* ══════════════════════════════════════════════════════════════════
     * MELANIN SYNTHESIS IN MELANOCYTE
     * ══════════════════════════════════════════════════════════════════
     *
     * Tyrosinase (p_tyr) oxidises tyrosine → DOPA → dopaquinone → eumelanin
     */
    p_tyr:  tyrosine     --> dopa;
    p_tyr:  dopa         --> dopaquinone;
    dopaquinone          --> eumelanin;

    /* MSH activates MC1R → upregulates tyrosinase via cAMP */
    p_mc1r: alpha_msh    --> msh_signal;
    msh_signal, tyrosine --> dopa, msh_signal;

    /* Melanosome packaging (p_msom) */
    p_msom: eumelanin, eumelanin, eumelanin --> melanosome;

    /* ══════════════════════════════════════════════════════════════════
     * MELANIN TRANSFER INHIBITION (PAR-2 block by niacinamide)
     * ══════════════════════════════════════════════════════════════════
     *
     * Niacinamide blocks PAR-2 signal → no melanosome capture by keratinocyte.
     * Without niacinamide: par2_signal triggers melanosome uptake.
     * With niacinamide: par2_signal is blocked → melanosomes not transferred.
     */
    /* Normal transfer: PAR-2 signal enables melanosome capture */
    p_par2: par2_signal, melanosome --> melanosome_keratin;

    /* Niacinamide competitively blocks PAR-2 signal */
    p_par2: niacinamide, par2_signal --> par2_blocked, niacinamide;

    /* With PAR-2 blocked: melanosome stays in dendrite channel */
    par2_blocked, melanosome --> melanosome;        /* no transfer          */

    /* ══════════════════════════════════════════════════════════════════
     * ANTI-GLYCATION (methylglyoxal trapping)
     * ══════════════════════════════════════════════════════════════════
     *
     * Niacinamide directly traps reactive carbonyl species (RCS)
     * such as methylglyoxal → prevents collagen crosslinking.
     */
    niacinamide, methylglyoxal --> niacinamide_mgly;  /* RCS trap           */

    /* Without niacinamide: methylglyoxal glycates collagen */
    p_glyc: methylglyoxal --> collagen_glycated;

    /* ══════════════════════════════════════════════════════════════════
     * BARRIER LIPID UPREGULATION (PPARα indirect)
     * ══════════════════════════════════════════════════════════════════
     *
     * NAD⁺ feeds PPARα co-factor pathway → ceramide + cholesterol synthesis.
     */
    nad_plus --> ceramide, cholesterol;

    /* ══════════════════════════════════════════════════════════════════
     * TILE ASSEMBLY
     * ══════════════════════════════════════════════════════════════════
     */
    @create niacinamide, niacinamide, niacinamide --> niacin_keratinocyte;
    @create tyrosine, tyrosine, alpha_msh          --> melanocyte;
    @create niacinamide, collagen_glycated         --> niacin_fibroblast;

    /* Melanocyte renewal */
    @divide glue_mel, msh_signal, glue_mel --> glue_mel, glue_mel;
}
